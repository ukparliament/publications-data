module Datagraphs
  module Api
    class GetPublications < CypherQuery

      QUERY = <<-Q
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)
        MATCH (pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label = 'Published'
        RETURN pe.id as publication_expression_id,
               pw.id as publication_work_id, pw.title as title,
               pes.label as status, pe.publishedAt as published_at,
               pe.teaserText as teaser_text, pe.createdAt as created_at,
               pe.number as the_number
        ORDER BY pe.publishedAt desc
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)
        MATCH (pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label="Published"
        RETURN count(pe) AS total
      Q

      def get_total
        params = { query: COUNT }
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def process(skip: 0, limit: 25)
        params = { query: QUERY % { skip: skip, limit: limit }}
        ap params
        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
