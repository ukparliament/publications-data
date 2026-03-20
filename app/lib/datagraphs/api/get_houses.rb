module Datagraphs
  module Api
    class GetHouses < CypherQuery

      QUERY = <<-Q
        MATCH houses=(house:House)-[r1:hasResearchService]->(rs:ResearchService)
        RETURN house.id as id, house.name as name, house.shortName AS short_name, house.isDefunct AS defunct, collect(rs.id) AS research_service_ids, collect(rs.name) AS research_service_names
      Q

      def process
        params = { query: QUERY }
        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
