module Datagraphs
  module Api
    class GetExpressions < CypherQuery

      QUERY = <<-Q
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
        OPTIONAL MATCH startWithPerson = (p:Person)<-[r3:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)
        OPTIONAL MATCH path3=(c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
        MATCH addStatus=(pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pw.id='%{publication_work_id}'
        RETURN    c.isPublic AS is_public,
                  pe.publishedAt AS published_at,
                  pe.teaserText AS teaser_text,
                  pw.title AS title,
                  pw.id AS publication_work_id,
                  pe.id AS id,
                  pes.label AS status,
                  pw.reference AS ref,
                  pe.createdAt AS created_at,
                  pes.label AS status,
                  COLLECT_LIST(DISTINCT p.id) AS people_ids,
                  COLLECT_LIST(DISTINCT p.displayName) AS people_names,
                  COLLECT_LIST(DISTINCT ct.label) AS contribution_types,
                  COLLECT_LIST(DISTINCT c.ordinality) AS ordinalities,
                  COLLECT_LIST(DISTINCT c.id) AS contribution_ids,
                  COLLECT_LIST(DISTINCT c.isPublic) AS public
        ORDER BY published_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      DYNAMIC_QUERY = <<-Q
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
        OPTIONAL MATCH startWithPerson = (p:Person)<-[r3:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)
        OPTIONAL MATCH path3=(c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
        MATCH addStatus=(pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pw.id='%{publication_work_id}'
        AND (%{statuses})
        RETURN    c.isPublic AS is_public,
                  pe.publishedAt AS published_at,
                  pe.teaserText AS teaser_text,
                  pe.title AS title,
                  pw.id AS publication_work_id,
                  pe.id AS id,
                  pes.label AS status,
                  pw.reference AS ref,
                  pe.createdAt AS created_at,
                  pes.label AS status,
                  COLLECT_LIST(DISTINCT p.id) AS people_ids,
                  COLLECT_LIST(DISTINCT p.displayName) AS people_names,
                  COLLECT_LIST(DISTINCT ct.label) AS contribution_types,
                  COLLECT_LIST(DISTINCT c.ordinality) AS ordinalities,
                  COLLECT_LIST(DISTINCT c.id) AS contribution_ids,
                  COLLECT_LIST(DISTINCT c.isPublic) AS public
        ORDER BY published_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
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
               p.name AS person_name,
               COLLECT_LIST(DISTINCT ct.label) AS contribution_types
        ORDER BY person_name
      Q

      RESOURCES_ONLY = <<-Q
        MATCH p = (pubWork:PublicationWork)<-[eO:expressionOf]-(pubExp:PublicationExpression)-[t:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH opt = (pubExp)-[r:hasResourceFileLink]->(resFileLink:ResourceFileLink)-[s:forResourceFile]->(resourceFile:ResourceFile)
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

      STATUSES = <<-Q
        MATCH p = (pw:PublicationWork)<-[e:expressionOf]-(b:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pw.id = '%{publication_work_id}'
        RETURN COLLECT_LIST(DISTINCT pes.label) AS statuses
      Q

      DYNAMIC_STATUS_COUNT = <<-Q
        MATCH p = (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pw.id = '%{publication_work_id}'
        AND (%{statuses})
        RETURN COUNT(pe) AS total
      Q

      def get_dynamic_status_count(publication_work_id: 'urn:publications-data:PublicationWork:3549', statuses:)
        params = { query: DYNAMIC_STATUS_COUNT % { publication_work_id: publication_work_id, statuses: statuses }}
        ap params
        response = call(params: params)
        ap response.body
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def dynamic_expressions(publication_work_id: 'urn:publications-data:PublicationWork:3549', skip: 0, limit: 25, statuses:)
        params = { query: DYNAMIC_QUERY % { publication_work_id: publication_work_id, skip: skip, limit: limit, statuses: statuses }}

        response = call(params: params)
        process_response(response.body)
      end

      def get_statuses(publication_work_id: 'urn:publications-data:PublicationWork:3549')
        params = { query: STATUSES % { publication_work_id: publication_work_id }}

        response = call(params: params)
        process_response(response.body)
      end

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

      def get_resources(publication_work_id: 'urn:publications-data:PublicationWork:7809')
        params = { query: RESOURCES_ONLY % { publication_work_id: publication_work_id }}

        response = call(params: params)
        ap response.body
        process_response(response.body)
      end
    end
  end
end
