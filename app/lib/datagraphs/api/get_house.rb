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

      QUERY_WITH_PUBLICATIONS_WITH_A_STATUS = <<-Q
        MATCH p = (pubWork:PublicationWork)-[hasE:hasExpression]->(pubExpression:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH q = (pubWork)-[s:publishedBy]->(rs:ResearchService)-[t:for]->(house:House)
        OPTIONAL MATCH r = (pubWork)-[d:hasWithdrawalPeriod]->(w:WithdrawalPeriod)
        WHERE pes.label = '%{publication_status_label}'
        AND house.id = '%{house_id}'
        RETURN pubExpression.publishedAt as published_at, pubExpression.title AS title, pubWork.id AS publication_work_id, w.id, pubExpression.id AS publication_expression_id, pubExpression.teaserText as teaser_text
        ORDER BY title
        SKIP %{skip}
        LIMIT %{limit}
      Q


      QUERY_WITH_PUBLICATIONS_WITH_A_STATUS_COUNT = <<-Q
        MATCH p = (pubWork:PublicationWork)-[hasE:hasExpression]->(pubExpression:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
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
