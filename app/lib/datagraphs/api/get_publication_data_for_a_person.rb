module Datagraphs
  module Api
    class GetPublicationDataForAPerson < CypherQuery

      QUERY = <<-Q
          MATCH startWithPerson=(p:Person)<-[r1:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
          MATCH getContributionType=(c:Contribution)-[r3:hasContributionType]->(ct:ContributionType)
          MATCH getPublicationWork=(pe:PublicationExpression)-[r5:expressionOf]->(pw:PublicationWork)
          WHERE p.id='%{person_id}' AND pes.label='Published'
          RETURN
            p.id AS person_id,
            p.name AS person_name,
            collect(c.ordinality) AS ordinality,
            c.isPublic AS is_public,
            pe.publishedAt AS published_at,
            pe.teaserText AS teaser_text,
            pw.title AS title,
            pw.id AS id,
            pes.label AS status,
            collect(ct.label) AS contribution_type,
            pw.reference AS ref,
            pw.publishedBy AS published_by,
            pe.createdAt AS created_at
          ORDER BY published_at desc, title asc
          SKIP %{skip}
          LIMIT %{limit}
      Q

      COUNT =  <<-Q
          MATCH startWithPerson=(p:Person)<-[r1:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
          MATCH getPublicationWork=(pe:PublicationExpression)-[r5:expressionOf]->(pw:PublicationWork)
          WHERE p.id='%{person_id}' AND pes.label='Published'
          RETURN COUNT(DISTINCT pe) AS total
      Q

      def process(person_id: 'urn:publications-data:Person:294313', skip: 0, limit: 25)
        params = { query: QUERY % { person_id: person_id, skip: skip, limit: limit }}
        response = call(params: params)
        process_response(response.body)
      end

      def get_total(person_id: 'urn:publications-data:Person:294313')
        params = { query: COUNT % { person_id: person_id }}
        response = call(params: params)
        ap response.body
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end
    end
  end
end
