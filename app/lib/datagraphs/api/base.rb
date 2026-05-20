module Datagraphs
  module Api
    class Base
      attr_reader :logger

      def call(body: default_body, params: default_params, method_type: default_method_type, logger: Rails.logger)
        @logger = logger

        request = Typhoeus::Request.new(
          url,
          method: method_type,
          body: body,
          params: params,
          headers: headers
        )

        # This is setting up a call back base on what might go wrong
        request.on_complete { |response| handle(response) }

        # This actually runs the request
        request.run
      end

      def default_method_type
        :get
      end

      def default_body
        {}
      end

      def default_params
        {}
      end

      def headers
        {
          ContentType: 'application/json',
          Accept: "application/json",
          'x-api-key': api_key,
          Authorization: "Bearer #{oauth_token}"
        }
      end

      private

      def handle(response)
        if response.success?
          logger.debug("Success")
        elsif response.timed_out?
          logger.warn("Request timed out")
        elsif response.code == 0
          logger.error(response.return_message)
        elsif response.code == 401 || response.code == 403
          logger.info("Access token has expired, delete tokens in database to trigger a fresh one")
          OAuthAccessToken.delete_all
        else
          # Received a non-successful http response.
          logger.warn("got an error")
          logger.error(response.return_message)
          logger.error(response.code.to_s)
        end
      end

      def api_key
        ENV.fetch('DATAGRAPHS_API_KEY')
      end

      def oauth_token
        token = OAuthAccessToken.first

        if token_needs_a_refresh?(token)
          logger.debug("Token is blank or has expired")
          token = GetOAuthToken.new.process
          logger.debug("We should now have a new token, expiring #{token.expires_in}")
        end
        token.token
      end

      def token_needs_a_refresh?(token)
        token.blank? || token.expires_in < Time.now
      end

      def project_id
        $DATAGRAPHS_PROJECT_ID
      end

      def url
        raise StandardException.new("This should be defined by subclass")
      end

      def base_url
        ENV.fetch('DATAGRAPHS_API_BASE_URL', 'https://api.datagraphs.io/')
      end
    end
  end
end
