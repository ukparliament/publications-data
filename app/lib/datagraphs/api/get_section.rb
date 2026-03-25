module Datagraphs
  module Api
    class GetSection < CypherQuery
      QUERY = <<-Q
        MATCH (s:Section)
        MATCH (s:Section)-[r1:formsPartOf]->(rs:ResearchService)
        WHERE
          s.id = '%{section_id}'
        RETURN s.id AS id, s.name AS name, s.shortName AS short_name, s.strapLine AS strap_line, s.isDefunct AS is_defunct, rs.id AS research_service_id, rs.name as research_service_name
        LIMIT 1
      Q

      def process(section_id = 'urn:publications-data:Section:1')
        Rails.logger.info("Calling get section for #{section_id}")
        params = { query: QUERY % { section_id: section_id }}

        response = call(params: params)
        Rails.logger.info("Called get section")
        ap response.body
        process_response(response.body)
      end
    end
  end
end
