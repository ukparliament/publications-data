module Datagraphs
  module Api
    class GetResearchService < CypherQuery

      QUERY = <<-Q
        MATCH path1=(rs:ResearchService)-[r1:for]->(h:House)
        MATCH path2=(pub:PublicationWork)-[p:publishedBy]->(rs)
        WHERE  rs.id='%{research_service_id}'
        RETURN rs.id AS id,
               rs.name AS name,
               rs.shortName AS short_name,
               rs.strapLine AS strap_line,
               rs.isDefunct AS is_Defunct,
               COUNT(pub) AS publication_count,
               COLLECT_LIST(DISTINCT h.id) AS house_ids,
               COLLECT_LIST(DISTINCT h.name) AS house_names
        LIMIT 1
      Q

      def process(research_service_id = 'urn:publications-data:ResearchService:1')
        params = { query: QUERY % { research_service_id: research_service_id }}

        ap params

        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
