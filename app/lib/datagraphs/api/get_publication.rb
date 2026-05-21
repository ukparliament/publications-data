module Datagraphs
  module Api
    class GetPublication < CypherQuery

      QUERY = <<-Q
        MATCH (pw:PublicationWork)-[r1:hasExpression]->(pe:PublicationExpression)
        OPTIONAL MATCH startWithPerson = (p:Person)<-[r3:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)
        OPTIONAL MATCH path3=(c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
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
                  COLLECT_LIST(DISTINCT pes.label) AS statuses,
                  COLLECT_LIST(DISTINCT p.id) AS people_ids,
                  COLLECT_LIST(DISTINCT p.name) AS people_names,
                  COLLECT_LIST(DISTINCT ct.label) AS contribution_types,
                  COLLECT_LIST(DISTINCT c.ordinality) AS ordinalities
        ORDER BY published_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      TEST_QUERY = <<-Q
        MATCH (pw:PublicationWork)-[r1:hasExpression]->(pe:PublicationExpression)
        OPTIONAL MATCH startWithPerson = (p:Person)<-[r3:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)
        OPTIONAL MATCH path3=(c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
        MATCH addStatus=(pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH path4=(pw:PublicationWork)-[r6:publishedBy]->(rs:ResearchService)
        WHERE pw.id='urn:publications-data:PublicationWork:3549'
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
                  COLLECT_LIST(DISTINCT pes.label) AS statuses,
                  COLLECT_LIST(DISTINCT p.id) AS people_ids,
                  COLLECT_LIST(DISTINCT p.name) AS people_names,
                  COLLECT_LIST(DISTINCT ct.label) AS contribution_types,
                  COLLECT_LIST(DISTINCT c.ordinality) AS ordinalities
        ORDER BY published_at DESC
        SKIP 0
        LIMIT 25
      Q

      TEST_QUERY_2 = <<-Q
        MATCH (pw:PublicationWork)-[r1:hasExpression]->(pe:PublicationExpression)
        MATCH addStatus=(pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH resource=(pe)-[r6:hasResourceFileLink]->(rfl:ResourceFileLink)
        WHERE pw.id='urn:publications-data:PublicationWork:3549'
        RETURN
                  pw.title AS title,
                  pe.id AS id,
                  pes.label AS status
        SKIP 0
        LIMIT 25

      Q

      COUNT = <<-Q
        MATCH (pw:PublicationWork)-[r1:hasExpression]->(pe:PublicationExpression)
        OPTIONAL MATCH path1=(pe:PublicationExpression)-[r2:hasContribution]->(c:Contribution)
        WHERE pw.id='%{publication_work_id}'
        RETURN COUNT(DISTINCT pe) AS total
      Q

      ALL_CONTRIBUTORS = <<-Q
        MATCH (pw:PublicationWork)-[r1:hasExpression]->(pe:PublicationExpression)
        MATCH startWithPerson = (p:Person)<-[r3:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)
        MATCH path3 = (c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
        WHERE pw.id='%{publication_work_id}'
        RETURN p.id AS person_id,
               p.name AS person_name,
               COLLECT_LIST(DISTINCT ct.label) AS contribution_types
        ORDER BY person_name
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

      def get_contributors(publication_work_id: 'urn:publications-data:PublicationWork:3549')
        params = { query: ALL_CONTRIBUTORS % { publication_work_id: publication_work_id }}

        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
