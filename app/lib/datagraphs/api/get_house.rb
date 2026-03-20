module Datagraphs
  module Api
    class GetHouse < CypherQuery

      QUERY = <<-Q
        MATCH houses=(house:House)-[r1:hasResearchService]->(rs:ResearchService)
        WHERE
          house.id='%{house_id}'
        RETURN house.name as name, house.shortName as short_name, house.isDefunct AS defunct, collect(rs.id) AS research_service_ids, collect(rs.name) AS research_service_names
        LIMIT 1
      Q

      def process(house_id = 'urn:publications-data:House:1')
        params = { query: QUERY % { house_id: house_id }}

        ap params

        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
