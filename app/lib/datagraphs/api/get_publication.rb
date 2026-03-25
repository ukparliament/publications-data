module Datagraphs
  module Api
    class GetPublication < CypherQuery

      QUERY = <<-Q
        MATCH startWithContribution=(c:Contribution)-[r4:contributionTo]->(pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r6:publishedBy]->(rs:ResearchService)
        MATCH addPerson=(c:Contribution)-[r2:contributionBy]->(p:Person)
        MATCH addContributionType=(c:Contribution)-[r3:hasContributionType]->(ct:ContributionType)
        MATCH addStatus=(pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pw.id='%{publication_work_id}'
        RETURN    c.isPublic AS is_public,
                  pe.publishedAt AS published_at,
                  pe.teaserText AS teaser_text,
                  pw.title AS title,
                  pe.id AS id,
                  pes.label AS status,
                  pw.reference AS ref,
                  rs.id AS research_service_id,
                  rs.name AS research_service_name,
                  pe.createdAt AS created_at,
                  COLLECT(DISTINCT pes.label) AS statuses,
                  COLLECT(DISTINCT p.id) AS people_ids,
                  COLLECT(DISTINCT p.name) AS people_names,
                  COLLECT(DISTINCT ct.label) AS contribution_types,
                  COLLECT(DISTINCT c.ordinality) AS ordinalities
        ORDER BY published_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q
        MATCH startWithContribution=(pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)
        WHERE pw.id='%{publication_work_id}'
        RETURN count(pe) AS total
      Q

      def process(publication_work_id: 'urn:publications-data:PublicationWork:3549', skip: 0, limit: 25)
        params = { query: QUERY % { publication_work_id: publication_work_id, skip: skip, limit: limit }}

        response = call(params: params)
        process_response(response.body)
      end

      def get_total(publication_work_id: 'urn:publications-data:PublicationWork:3549')
        params = { query: COUNT % { publication_work_id: publication_work_id }}
        response = call(params: params)
        ap response.body
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end
    end
  end
end
