module SamlSso
  class AuthenticationController < ApplicationController

    # This is coming back from Entra, so we skip the token check
    # and disable CSRF
    skip_before_action :verify_authenticity_token, only: :create

    # With acknowledgement of the work done by
    # https://freelancing-gods.com/2025/05/06/saml-ruby-service-provider

    # So when we want to log in, we hit *this* endpoint, which is going to
    # set up the request and redirect us to Entra ID
    def new
      # Generate a new SAML request
      saml_request = OneLogin::RubySaml::Authrequest.new

      # Send the current visitor away to the IdP:
      redirect_to(
        saml_request.create(
          # These are settings for the specific IdP:
          saml_settings,
          # This is your own context/state, which the IdP does not
          # care about but it will send it back to you:
          RelayState: root_path
        ),
        # Ensure Rails is okay with you redirecting people away to
        # a different site:
        allow_other_host: true
      )
    end

    # This is where we are going to get redirected back to from Entra
    def create
      # Parse the given SAML response from MS
      saml_response = OneLogin::RubySaml::Response.new(
        params[:SAMLResponse]
      )
      # And apply the same IdP configuration settings
      saml_response.settings = saml_settings

      # If it's a valid response, then we have a confirmed identity
      # and can log the visitor in:
      if saml_response.is_valid?
        logger.info "Valid saml response"
        session[:user_id] = saml_response.nameid
        message = "You have successfully logged in"
      else
        # Otherwise, the response is invalid - you'll probably want
        # to provide some feedback and ask people to try logging in
        # again.
        # ...
        logger.error "Invalid saml response"
        message = "There was a problem logging you in"
      end

      redirect_to root_path, notice: message
    end

    # Initiate logout - redirect user to this URL in Entra settings
    def destroy

      # LogoutRequest accepts plain browser requests w/o paramters
      settings = saml_settings

      if settings.idp_slo_service_url.nil?
        logger.info "SLO IdP Endpoint not found in settings, then executing a normal logout'"
        delete_session
      else
        logout_request = OneLogin::RubySaml::Logoutrequest.new
        logger.info "New SP SLO for userid '#{session[:userid]}' transactionid '#{logout_request.uuid}'"

        if settings.name_identifier_value.nil?
          settings.name_identifier_value = session[:user_id]
        end

        # Ensure user is logged out before redirect to IdP, in case anything goes wrong during single logout process (as recommended by saml2int [SDP-SP34])
        logged_user = session[:user_id]
        logger.info "Delete session for '#{session[:user_id]}'"
        delete_session

        # Save the transaction_id to compare it with the response we get back
        session[:transaction_id] = logout_request.uuid
        session[:logged_out_user] = logged_user

        logger.info "Redirect to MS to log out"
        redirect_to(logout_request.create(settings, RelayState: root_path), allow_other_host: true)
      end
    end

    # Handle the response back from Entra
    def saml_logout
      ap "We should come back here, but maybe we are not?"
      if session.has_key? :transaction_id
        logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], saml_settings, :matches_request_id => session[:transaction_id])
      else
        logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], saml_settings)
      end

      logger.info "LogoutResponse is: #{logout_response.to_s}"

      # Validate the SAML Logout Response
      if not logout_response.validate
        logger.error "The SAML Logout Response is invalid"
      else
        # Actually log out this session
        logger.info "SLO completed for '#{session[:logged_out_user]}'"
        delete_session
      end

      redirect_to root_path, alert: "You have been logged out"
    end

    def metadata; end

    private

    # Delete a user's session, belt and braces
    def delete_session
      session[:user_id] = nil
      session[:userid] = nil

      session[:attributes] = nil
      session[:transaction_id] = nil
      session[:logged_out_user] = nil
    end

    def idp_metadata_url
      ENV.fetch("ENTRA_APP_FEDERATION_METADATA_URL")
    end

    def sdp_callback_url
      ENV.fetch("ENTRA_APP_LOGIN_CALLBACK_URL")
    end

    def sdp_entity_id
      ENV.fetch("ENTRA_APP_ENTITY_ID")
    end

    def saml_settings
      # From a local file
      # metadata_xml = File.read('sso/saml-sso-test.xml')

      # Or fetched from the URL directly
      metadata_xml = Net::HTTP.get(URI(idp_metadata_url))

      idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
      settings = idp_metadata_parser.parse(metadata_xml)

      # Where the IdP sends users back to on our site:
      settings.assertion_consumer_service_url = sdp_callback_url

      # A unique identifier of our service, sometimes requested by
      # the IdP:
      settings.sp_entity_id = sdp_entity_id

      settings
    end
  end
end