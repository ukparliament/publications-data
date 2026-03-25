module Datagraphs
  module Api
    class GetSections < CypherQuery

      QUERY = <<-Q
        MATCH (s:Section)
        MATCH (s:Section)-[r1:formsPartOf]->(rs:ResearchService)
        RETURN s.id AS id, s.name AS name, s.shortName AS short_name, s.strapLine AS strap_line, s.isDefunct AS is_defunct, rs.id AS research_service_id, rs.name as research_service_name
        ORDER BY s.isDefunct, s.name
      Q

      def process
        Rails.logger.info("Calling get sections")
        params = { query: QUERY }
        response = call(params: params)
        Rails.logger.info("Called get sections")
        process_response(response.body)
      end
    end
  end
end
