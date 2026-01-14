module Datagraphs
  module Api
    class Base
      def call(body, params)
        request = Typhoeus::Request.new(
          base_url,
          method: method_type,
          body: body,
          params: params,
          headers: headers
        )
      end

      def method_type
        :get
      end

      def body
        {}
      end

      def params
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
        ENV.fetch('DATAGRAPHS_OAUTH_TOKEN')
      end

      def base_url
        ENV.fetch('DATAGRAPHS_API_BASE_URL', 'https://api.datagraphs.io/')
      end
    end
  end
end