module Datagraphs
  module Api
    class GetHouses < CypherQuery

      QUERY = <<-Q
        MATCH p = (house:House)<-[r1:for]-(rs:ResearchService)
        RETURN house.id as id,
               house.name as name,
               house.shortName AS short_name,
               COLLECT_LIST(rs.id) AS research_service_ids,
               COLLECT_LIST(rs.name) AS research_service_names
        ORDER BY house.name
      Q

      def process
        Rails.logger.info("Calling get houses")
        params = { query: QUERY }
        response = call(params: params)
        Rails.logger.info("Called get houses")
        process_response(response.body)

      end
    end
  end
end
