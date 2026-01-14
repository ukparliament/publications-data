module Datagraphs
  module Api
    class GetDatasets < Base
      def call(body = default_body, params = default_params)
        request = Typhoeus::Request.new(
          url,
          method: method_type,
          body: body,
          params: params,
          headers: headers
        )
        request.run
      end

      def method_type
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

      def url
        "#{base_url}#{project_id}"
      end

      def project_id
        "subject-specialist-finder"
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