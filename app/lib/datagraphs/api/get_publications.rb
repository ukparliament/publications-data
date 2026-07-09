module Datagraphs
  module Api
    class GetPublications < CypherQuery

      QUERY = <<-Q
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs:ResearchService)
        MATCH (pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label = 'Published'
        RETURN pe.id as publication_expression_id,
               pw.id as publication_work_id, pw.title as title,
               pes.label as status, pe.publishedAt as published_at,
               pe.teaserText as teaser_text, pe.createdAt as created_at,
               pe.number as the_number,
               rs.shortName AS short_research_service_name,
               rs.id AS research_service_id
        ORDER BY pe.publishedAt desc
        SKIP %{skip}
        LIMIT %{limit}
      Q

      FOR_A_RESEARCH_SERVICE = <<-Q
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs:ResearchService)
        MATCH (pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label = 'Published'
        AND rs.id = '%{research_service_id}'
        RETURN pe.id as publication_expression_id,
               pw.id as publication_work_id, pw.title as title,
               pes.label as status, pe.publishedAt as published_at,
               pe.teaserText as teaser_text, pe.createdAt as created_at,
               pe.number as the_number,
               rs.shortName AS short_research_service_name,
               rs.id AS research_service_id
        ORDER BY pe.publishedAt desc
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT_FOR_RESEARCH_SERVICE = <<-Q
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs:ResearchService)
        MATCH (pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label="Published"
        AND rs.id = '%{research_service_id}'
        RETURN count(pw) AS total
      Q

      COUNT = <<-Q
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)
        MATCH (pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label="Published"
        RETURN count(pw) AS total
      Q

      UNPUBLISHED_FOR_A_HOUSE_COUNT = <<-Q.squish
        OPTIONAL MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[s:publishedBy]->(d:ResearchService)-[f:for]->(h:House)
        WHERE pes.label = 'Published'
        AND h.id = '%{house_id}'
        RETURN pw, count(pe) AS expression_count
        NEXT YIELD pw, expression_count
        FILTER expression_count = 0
        RETURN COUNT(DISTINCT pw.id) AS total
      Q

      UNPUBLISHED_FOR_A_HOUSE = <<-Q.squish
        OPTIONAL MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[s:publishedBy]->(d:ResearchService)-[f:for]->(h:House)
        WHERE pes.label = 'Published'
        AND h.id = '%{house_id}'
        RETURN pw, count(pe) AS expression_count
        NEXT YIELD pw, expression_count
        FILTER expression_count = 0
        MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)
        RETURN
               pw.id as publication_work_id,
               pw.title as work_title,
               COLLECT_LIST(pe.id) AS expression_ids,
               COLLECT_LIST(pe.title) AS expression_titles
        ORDER BY expression_titles
      Q

      def get_for_a_research_service(research_service_id:, skip: 0, limit: 25)
        params = { query: FOR_A_RESEARCH_SERVICE % { skip: skip, limit: limit, research_service_id: research_service_id }}
        ap params
        response = call(params: params)
        process_response(response.body)
      end

      def get_count_for_a_research_service(research_service_id)
        params = { query: COUNT_FOR_RESEARCH_SERVICE % {  research_service_id: research_service_id }}
        ap params
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

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

      def unpublished_for_a_house(house_id:, skip: 0, limit: 25)
        params = { query: UNPUBLISHED_FOR_A_HOUSE % { house_id: house_id, skip: skip, limit: limit }}
        response = call(params: params)
        process_response(response.body)
      end

      def unpublished_for_a_house_count(house_id:)
        params = { query: UNPUBLISHED_FOR_A_HOUSE_COUNT % { house_id: house_id }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end
    end
  end
end
