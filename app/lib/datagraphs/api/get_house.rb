module Datagraphs
  module Api
    class GetHouse < CypherQuery

      QUERY = <<-Q
        MATCH houses=(house:House)<-[r1:for]-(rs:ResearchService)
        WHERE
          house.id='%{house_id}'
        RETURN house.name as name,
               house.shortName as short_name,
               house.isDefunct AS defunct,
               collect_list(rs.id) AS research_service_ids,
               collect_list(rs.name) AS research_service_names
        LIMIT 1
      Q

      QUERY_WITH_PUBLICATIONS_WITH_A_STATUS = <<-Q
        MATCH p = (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH q = (pw)-[s:publishedBy]->(rs:ResearchService)-[t:for]->(house:House)
        OPTIONAL MATCH r = (pw)-[d:hasWithdrawalPeriod]->(w:WithdrawalPeriod)
        WHERE pes.label = '%{publication_status_label}'
        AND house.id = '%{house_id}'
        RETURN pe.publishedAt AS published_at,
               pe.createdAt AS created_at,
               pe.title AS title,
               pw.id AS publication_work_id,
               w.id AS withdrawl_period_id,
               pe.id AS publication_expression_id,
               pe.teaserText AS teaser_text,
               rs.name AS research_service_name,
               rs.shortName AS research_service_short_name,
               rs.id AS research_service_id
        ORDER BY published_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q


      QUERY_WITH_PUBLICATIONS_WITH_A_STATUS_COUNT = <<-Q
        MATCH p = (pubWork:PublicationWork)<-[eO:expressionOf]-(pubExpression:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH q = (pubWork)-[s:publishedBy]->(rs:ResearchService)-[t:for]->(house:House)
        OPTIONAL MATCH r = (pubWork)-[d:hasWithdrawalPeriod]->(w:WithdrawalPeriod)
        WHERE pes.label = '%{publication_status_label}'
        AND house.id = '%{house_id}'
        RETURN count(pubWork.id) AS total
      Q

      def process(house_id = 'urn:publications-data:House:1')
        params = { query: QUERY % { house_id: house_id }}
        response = call(params: params)
        process_response(response.body)
      end

      def house_with_publications_with_a_status_count(house_id: 'urn:publications-data:House:1', publication_status_label: 'Published')

        params = { query: QUERY_WITH_PUBLICATIONS_WITH_A_STATUS_COUNT % { house_id: house_id, publication_status_label: publication_status_label }}

        ap params
        response = call(params: params)
        ap response.body
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def house_with_publications_with_a_status(house_id: 'urn:publications-data:House:1', publication_status_label: 'Published', skip: 0, limit: 100)
        params = { query: QUERY_WITH_PUBLICATIONS_WITH_A_STATUS % { house_id: house_id, publication_status_label: publication_status_label, skip: skip, limit: limit }}
        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
