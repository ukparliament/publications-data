module Datagraphs
  module Api
    class GetPublication < CypherQuery

      QUERY = <<-Q
        MATCH (pw:PublicationWork)-[r1:hasExpression]->(pe:PublicationExpression)
        MATCH path1=(pe:PublicationExpression)-[r2:hasContribution]->(c:Contribution)
        MATCH path2=(c:Contribution)-[r3:contributionBy]->(p:Person)
        MATCH path3=(c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
        MATCH addStatus=(pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH path4=(pw:PublicationWork)-[r6:publishedBy]->(rs:ResearchService)
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
        MATCH (pw:PublicationWork)-[r1:hasExpression]->(pe:PublicationExpression)
        MATCH path1=(pe:PublicationExpression)-[r2:hasContribution]->(c:Contribution)
        WHERE pw.id='%{publication_work_id}'
        RETURN COUNT(DISTINCT pe) AS total
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
