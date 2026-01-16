module Datagraphs
  module Api
    class Base
      def call(body: default_body, params: default_params, method_type: default_method_type)
        request = Typhoeus::Request.new(
          url,
          method: method_type,
          body: body,
          params: params,
          headers: headers
        )

        request.on_complete do |response|
          if response.success?
            # hell yeah
          elsif response.timed_out?
            # aw hell no
            Rails.logger.warning("got a time out")
          elsif response.code == 0
            # Could not get an http response, something's wrong.
            Rails.logger.error(response.return_message)
          elsif response.code == 401 || response.code == 403
            Rails.logger.info("Access token has expired")
            OAuthAccessToken.delete_all
          else
            # Received a non-successful http response.
            Rails.logger.warning("got an error")
            Rails.logger.error(response.return_message)
            Rails.logger.error(response.code.to_s)
          end
        end

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
        api_key = ENV.fetch('DATAGRAPHS_API_KEY')
        {
          ContentType: 'application/json',
          Accept: "application/json",
          'x-api-key': api_key,
          Authorization: "Bearer #{oauth_token}"
        }
      end

      private

      def api_key
        ENV.fetch('DATAGRAPHS_API_KEY')
      end

      def oauth_token
        # TODO - if this has already expired, get a new on here.
        token = OAuthAccessToken.first

        if token.blank? || token.expires_in < Time.now
          ap "Token has expired"
          token = GetOAuthToken.new.process
        end
        token.token
      end

      def project_id
        "subject-specialist-finder"
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