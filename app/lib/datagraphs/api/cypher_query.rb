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
    end
  end
end