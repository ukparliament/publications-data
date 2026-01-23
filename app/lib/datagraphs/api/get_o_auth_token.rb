module Datagraphs
  module Api
    class GetOAuthToken < Base
      def process
        response = call(
          body: {
            clientId: client_id,
            clientSecret: client_secret
          },
          method_type: :post
        )

        process_response(response.body)
      end

      def process_response(response)
        json_response = JSON.parse(response)

        expires_in = Time.now + json_response["expires_in"].seconds

        OAuthAccessToken.delete_all
        OAuthAccessToken.create(
          token: json_response["access_token"],
          expires_in: expires_in
        )
      end

      def url
        "#{base_url}oauth/token"
      end

      def client_secret
        ENV.fetch('DATAGRAPHS_CLIENT_SECRET')
      end

      def client_id
        ENV.fetch('DATAGRAPHS_CLIENT_ID')
      end

      # Override as we don't have a token!
      def headers
        api_key = ENV.fetch('DATAGRAPHS_API_KEY')

        {
          ContentType: 'application/json',
          Accept: "application/json",
          'x-api-key': api_key
        }
      end
    end
  end
end
