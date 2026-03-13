module Datagraphs
  module Api
    class GetPublicationDataForAPerson < Base

      QUERY = <<-Q
          MATCH startWithPerson=(p:Person)<-[r1:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
          MATCH getContributionType=(c:Contribution)-[r3:hasContributionType]->(ct:ContributionType)
          MATCH getPublicationWork=(pe:PublicationExpression)-[r5:expressionOf]->(pw:PublicationWork)
          WHERE p.id='%{person_id}'
          RETURN
            p.id AS person_id,
            p.name AS person_name,
            c.ordinality AS ordinality,
            c.isPublic AS is_public,
            pe.publishedAt AS published_at,
            pe.teaserText AS teaser_text,
            pw.title AS title,
            pe.id AS id,
            pes.label AS status,
            ct.label AS contribution_type,
            pw.reference AS reference,
            pw.publishedBy AS published_by,
            pe.createdAt AS created_at
          ORDER BY pe.publishedAt desc
      Q

      def process(person_id = 'urn:publications-data:Person:294313')
        params = { query: QUERY % { person_id: person_id }}
        response = call(params: params)
        process_response(response.body)
      end

      def process_response(response)
        json_response = JSON.parse(response)
        json_response["results"]
      end

      def url
        "#{base_url}#{project_id}/_cypher"
      end

      def process_single_record(single_record)
       # ap single_record
      end
    end
  end
end
