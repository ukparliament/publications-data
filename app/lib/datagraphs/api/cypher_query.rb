module Datagraphs
  module Api
    class CypherQuery < Base
      def url
        "#{base_url}#{project_id}/_cypher"
      end

      def process_response(response)
        json_response = JSON.parse(response)
        json_response["results"]
      end

      private

      def generic_count(params:)
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end
    end
  end
end
