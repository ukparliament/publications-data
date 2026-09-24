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
        params = { query: QUERY }
        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
