module Datagraphs
  module Api
    class GetExpression < CypherQuery

      QUERY = <<-Q
      MATCH path0 = (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)-[t:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
      WHERE pe.id = '%{expression_id}'
      RETURN pe.title AS title,
             pe.publishedAt AS published_at,
             pe.teaserText AS teaser_text,
             pw.id AS publication_work_id,
             pes.label AS status,
             pw.reference AS ref,
             pe.createdAt AS created_at
      Q

      TEST_QUERY = <<-Q
      MATCH path0 = (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)-[t:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
      MATCH path2 = (pe)<-[u:contributionTo]-(c:Contribution)-[v:contributionBy]->(p:Person)
      MATCH path3 = (c)-[w:hasContributionType]->(ct:ContributionType)
      OPTIONAL MATCH path4 = (pe)<-[x:relatedLinkFor]-(rl:RelatedLink)
      WHERE pe.id = 'urn:publications-data:PublicationExpression:23577'
      RETURN pe.title AS title,
             pe.publishedAt AS published_at,
             pe.teaserText AS teaser_text,
             COLLECT_LIST(p.displayName) AS people_names,
             COLLECT_LIST(p.id) AS people_ids,
             COLLECT_LIST(ct.label) AS contribution_types,
             COLLECT_LIST( DISTINCT rf.id) AS resource_file_id,
             COLLECT_LIST(DISTINCT rl.id) AS related_link_ids,
             pw.id AS publication_work_id,
             pes.label AS status,
             pw.reference AS ref,
             pe.createdAt AS created_at,
             c.isPublic AS is_public
      Q

      CONTRIBUTORS = <<-Q
        MATCH startWithPerson = (p:Person)<-[r3:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)
        MATCH path3 = (c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
        WHERE pe.id='%{expression_id}'
        RETURN p.id AS person_id,
               p.displayName AS person_name,
               COLLECT_LIST(DISTINCT ct.label) AS contribution_types,
               c.isPublic AS is_public
        ORDER BY p.sortName
      Q

      RESOURCES = <<-Q
        MATCH path2 = (pe:PublicationExpression)<-[r:forPublicationExpression]-(rfl:ResourceFileLink)-[s:forResourceFile]->(rf:ResourceFile)
        WHERE pe.id = '%{expression_id}'
        RETURN
          rf.id as id,
          rfl.title as file_title,
          rf.label as file_label,
          rf.fileType as file_type,
          rf.mimeType as mime_type,
          rf.fileSizeInBytes as file_size_in_bytes,
          rf.publicUrl as public_url,
          rf.privateUrl as private_url
      Q

      RELATED_LINKS  = <<-Q
        MATCH path4 = (pe:PublicationExpression)<-[x:relatedLinkFor]-(rl:RelatedLink)
        WHERE pe.id = '%{expression_id}'
        RETURN rl.id AS id,
               rl.title AS title,
               rl.url AS url
      Q

      SECTIONS = <<-Q
        MATCH p = (pe:PublicationExpression)<-[e:sectionContributionTo]-(b:SectionContribution)-[r:sectionContributionBy]->(s:Section)
        WHERE pe.id = '%{expression_id}'
        RETURN s.name AS name, s.id AS id
        ORDER BY s.name
      Q

      def process(expression_id: 'urn:publications-data:PublicationExpression:69185')
        params = { query: QUERY % { expression_id: expression_id }}
        ap params
        response = call(params: params)
        process_response(response.body)
      end

      def resources(expression_id: 'urn:publications-data:PublicationExpression:69185')
        params = { query: RESOURCES % { expression_id: expression_id }}
        ap params
        response = call(params: params)
        process_response(response.body)
      end

      def related_links(expression_id: 'urn:publications-data:PublicationExpression:69185')
        params = { query: RELATED_LINKS % { expression_id: expression_id }}
        ap params
        response = call(params: params)
        process_response(response.body)
      end

      def contributors(expression_id: 'urn:publications-data:PublicationExpression:69185')
        params = { query: CONTRIBUTORS % { expression_id: expression_id }}
        ap params
        response = call(params: params)
        process_response(response.body)
      end

      def sections(expression_id: 'urn:publications-data:PublicationExpression:69185')
        params = { query: SECTIONS % { expression_id: expression_id }}
        ap params
        response = call(params: params)
        process_response(response.body)
      end

    end
  end
end
