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
                  pw.reference AS reference,
                  rs.id AS research_service_id,
                  rs.name AS research_service_name,
                  pe.createdAt AS created_at,
                  COLLECT(DISTINCT pes.label) AS statuses,
                  COLLECT(DISTINCT p.id) AS people_ids,
                  COLLECT(DISTINCT p.name) AS people_names,
                  COLLECT(DISTINCT ct.label) AS contribution_types,
                  COLLECT(DISTINCT c.ordinality) AS ordinalities
      Q

      Q2 = "
MATCH (c:Contribution)-[r4:contributionTo]->(pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r6:publishedBy]->(rs:ResearchService)
MATCH (c:Contribution)-[r2:contributionBy]->(p:Person)
MATCH (c:Contribution)-[r3:hasContributionType]->(ct:ContributionType)
OPTIONAL MATCH (pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
WHERE pw.id='urn:publications-data:PublicationWork:15617'
RETURN pe.id AS id,
pe.publishedAt AS published_at,
pe.teaserText AS teaser_text,
pe.createdAt AS created_at,
pw.title AS title,
pw.reference AS reference,
rs.id AS research_service_id,
rs.name AS research_service_name,
collect(distinct pes.label) AS statuses,
collect(distinct p.id) AS person_ids,
collect(distinct p.name) AS person_names,
collect(distinct ct.label) AS contribution_types,
collect(distinct c.ordinality) AS ordinalities


      "




      def process(publication_work_id = 'urn:publications-data:PublicationWork:3549')
        params = { query: QUERY % { publication_work_id: publication_work_id }}

        ap params

        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
