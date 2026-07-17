module Datagraphs
  module Api
    class GetResearchServices < CypherQuery

      QUERY = <<-Q.squish
        MATCH path1 = (rs:ResearchService)-[r1:for]->(h:House)
        MATCH path2 = (pe:PublicationExpression)-[r2:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs)
        MATCH path3 = (pe)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label = "Published"
        RETURN rs.id AS id,
              rs.name AS name,
              rs.shortName AS short_name,
              COUNT(DISTINCT pw) AS publication_count,
              COLLECT_LIST(DISTINCT h.id) AS house_ids,
              COLLECT_LIST(DISTINCT h.name) AS house_names
        ORDER BY name ASC
      Q

      def process
        Rails.logger.info("Calling get research services")
        params = { query: QUERY }
        ap params
        response = call(params: params)
        Rails.logger.info("Called get research services")
        process_response(response.body)
      end
    end
  end
end
