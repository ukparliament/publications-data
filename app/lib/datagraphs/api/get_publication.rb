module Datagraphs
  module Api
    class GetPublication < CypherQuery
      PUBLISHED_PUBLICATION_ONLY = <<-Q
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
        MATCH addStatus=(pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH path4=(pw:PublicationWork)-[r6:publishedBy]->(rs:ResearchService)
        WHERE pw.id='%{publication_work_id}'
        AND pes.label = 'Published'
        RETURN    pw.title AS title,
                  pe.teaserText AS teaser_text,
                  pw.id AS id,
                  pes.label AS status,
                  pw.reference AS ref,
                  rs.id AS research_service_id,
                  rs.name AS research_service_name,
                  pe.createdAt AS created_at,
                  pe.publishedAt AS published_at
      Q

      QUERY = <<-Q
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
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
                  COLLECT_LIST(DISTINCT p.displayName) AS people_names,
                  COLLECT_LIST(DISTINCT ct.label) AS contribution_types,
                  COLLECT_LIST(DISTINCT c.ordinality) AS ordinalities
        ORDER BY published_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      TEST_QUERY = <<-Q
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
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
                  COLLECT_LIST(DISTINCT p.displayName) AS people_names,
                  COLLECT_LIST(DISTINCT ct.label) AS contribution_types,
                  COLLECT_LIST(DISTINCT c.ordinality) AS ordinalities
        ORDER BY published_at DESC
        SKIP 0
        LIMIT 25
      Q

      TEST_QUERY_2 = <<-Q
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
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
        MATCH p = (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
        OPTIONAL MATCH path1=(pe:PublicationExpression)<-[r2:contributionTo]-(c:Contribution)
        WHERE pw.id='%{publication_work_id}'
        RETURN COUNT(DISTINCT pe) AS total
      Q

      ALL_CONTRIBUTORS = <<-Q
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
        MATCH startWithPerson = (p:Person)<-[r3:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)
        MATCH path3 = (c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
        WHERE pw.id='%{publication_work_id}'
        RETURN p.id AS person_id,
               p.displayName AS person_name,
               ct.label AS contribution_type,
               c.isPublic AS is_contribution_public,
               c.ordinality AS contribution_ordinality,
               c.label AS contribution_label
        ORDER BY person_name
      Q

      RESOURCES_ONLY = <<-Q
        MATCH p = (pubWork:PublicationWork)<-[eO:expressionOf]-(pubExp:PublicationExpression)-[t:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH opt = (pubExp)<-[r:forPublicationExpression]-(resFileLink:ResourceFileLink)-[s:forResourceFile]->(resourceFile:ResourceFile)
        WHERE pubWork.id = '%{publication_work_id}'
        AND pes.label = "Published"
        RETURN
              resFileLink.title as file_title,
              resourceFile.label as file_label,
              resourceFile.fileType as file_type,
              resourceFile.mimeType as mime_type,
              resourceFile.fileSizeInBytes as file_size_in_bytes,
              resourceFile.publicUrl as public_url,
              resourceFile.privateUrl as private_url
      Q

      TEST_RESOURCES_ONLY  = <<-Q
        MATCH p = (pubWork:PublicationWork)-[e:hasExpression]->(pubExp:PublicationExpression)-[t:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH opt = (pubExp)<-[r:forPublicationExpression]-(resFileLink:ResourceFileLink)-[s:forResourceFile]->(resourceFile:ResourceFile)
        WHERE pubWork.id = '15049'
        AND pes.label = "Published"
        RETURN pubWork.id as publication_id,
              pubWork.title as publication_title,
              resFileLink.title as file_title,
              resourceFile.label as file_label,
              resourceFile.fileType as file_type,
              resourceFile.mimeType as mime_type,
              resourceFile.fileSizeInBytes as file_size_in_bytes,
              resourceFile.publicUrl as public_url,
              resourceFile.privateUrl as private_url
      Q

      def process(publication_work_id: 'urn:publications-data:PublicationWork:3549', skip: 0, limit: 25)
        params = { query: QUERY % { publication_work_id: publication_work_id, skip: skip, limit: limit }}

        response = call(params: params)
        process_response(response.body)
      end

      def get_published_publication_details(publication_work_id: 'urn:publications-data:PublicationWork:3549')
        params = { query: PUBLISHED_PUBLICATION_ONLY % { publication_work_id: publication_work_id }}

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

      def get_resources(publication_work_id: 'urn:publications-data:PublicationWork:7809')
        params = { query: RESOURCES_ONLY % { publication_work_id: publication_work_id }}

        response = call(params: params)
        ap response.body
        process_response(response.body)
      end
    end
  end
end
