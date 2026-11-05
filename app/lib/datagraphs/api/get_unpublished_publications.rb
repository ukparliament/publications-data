module Datagraphs
  module Api
    class GetUnpublishedPublications < CypherQuery
      QUERY = <<-Q
        OPTIONAL MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[s:publishedBy]->(d:ResearchService)-[f:for]->(h:House)
        WHERE pes.label = 'Published'
        RETURN pw, count(pe) AS expression_count
        NEXT YIELD pw, expression_count
        FILTER expression_count = 0
        MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[r6:publishedBy]->(rs:ResearchService)
        OPTIONAL MATCH (person:Person)<-[r4:contributionBy]-(cont:Contribution)-[r5:contributionTo]->(pe)
        RETURN pe.id as publication_expression_id,
               pw.id as publication_work_id,
               pe.title as title,
               pes.label as status,
               pw.createdOn as created_at,
               pe.number as version_number,
               pe.updatedAt AS updated_at,
               rs.shortName AS short_research_service_name,
               rs.id AS research_service_id,
               COLLECT_LIST(DISTINCT person.id) AS contributor_ids,
               COLLECT_LIST(DISTINCT person.displayName) AS contributor_names
        ORDER BY updated_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q
        OPTIONAL MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[s:publishedBy]->(d:ResearchService)-[f:for]->(h:House)
        WHERE pes.label = 'Published'
        RETURN pw, count(pe) AS expression_count
        NEXT YIELD pw, expression_count
        FILTER expression_count = 0
        RETURN COUNT(DISTINCT pw) AS total
      Q

      UNPUBLISHED_COUNT_FOR_GENERIC = <<-Q.squish
        OPTIONAL MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        %{sub_query}
        AND pes.label = 'Published'
        RETURN pw, count(pe) AS expression_count
        NEXT YIELD pw, expression_count
        FILTER expression_count = 0

        RETURN COUNT(DISTINCT pw.id) AS total
      Q

      UNPUBLISHED_FOR_A_HOUSE_SUB_QUERY = <<-Q.squish
        MATCH (pw:PublicationWork)-[s:publishedBy]->(d:ResearchService)-[f:for]->(h:House)
        WHERE h.id = '%{house_id}'
      Q

      UNPUBLISHED_FOR_A_RESEARCH_SERVICE_SUB_QUERY =  <<-Q.squish
        MATCH (pw:PublicationWork)-[s:publishedBy]->(d:ResearchService)
        WHERE d.id = '%{research_service_id}'
      Q

      UNPUBLISHED_FOR_A_SECTION_SUB_QUERY =  <<-Q.squish
        MATCH (s:Section)<-[scb:sectionContributionBy]-(sc:SectionContribution)-[sct:sectionContributionTo]->(pe:PublicationExpression)
        WHERE s.id = '%{section_id}'
      Q

      UNPUBLISHED_FOR_A_GENERIC = <<-Q.squish
        OPTIONAL MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        %{sub_query}
        AND pes.label = 'Published'
        RETURN pw, count(pe) AS expression_count
        NEXT YIELD pw, expression_count
        FILTER expression_count = 0
        MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH (pw:PublicationWork)-[r6:publishedBy]->(rs:ResearchService)
        OPTIONAL MATCH (person:Person)<-[r4:contributionBy]-(cont:Contribution)-[r5:contributionTo]->(pe)
        RETURN pe.id as publication_expression_id,
               pw.id as publication_work_id,
               pe.title as title,
               pes.label as status,
               pw.createdOn as created_at,
               pe.number as version_number,
               pe.updatedAt AS updated_at,
               rs.shortName AS short_research_service_name,
               rs.id AS research_service_id,
               COLLECT_LIST(DISTINCT person.id) AS contributor_ids,
               COLLECT_LIST(DISTINCT person.displayName) AS contributor_names
        ORDER BY updated_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      def get_total
        params = { query: COUNT }
        generic_count(params: params)
      end

      def all(skip: 0, limit: 25)
        params = { query: QUERY % { skip: skip, limit: limit }}
        response = call(params: params)
        publications = process_response(response.body)

        publications.each do |pub|
          pub["owners"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.each do |pub|
          pub["contributors"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.map { |publication| Hashie::Mash.new(publication) }
      end

      def for_a_house(house_id:, skip: 0, limit: 25)
        sub_query = UNPUBLISHED_FOR_A_HOUSE_SUB_QUERY % { house_id: house_id }
        unpublished_for_a_generic(sub_query: sub_query, skip: skip, limit: 25)
      end

      def for_a_section(section_id:, skip: 0, limit: 25)
        sub_query = UNPUBLISHED_FOR_A_SECTION_SUB_QUERY % { section_id: section_id }
        unpublished_for_a_generic(sub_query: sub_query, skip: skip, limit: 25)
      end

      def for_a_research_service(research_service_id:, skip: 0, limit: 25)
        sub_query = UNPUBLISHED_FOR_A_RESEARCH_SERVICE_SUB_QUERY % { research_service_id: research_service_id }
        unpublished_for_a_generic(sub_query: sub_query, skip: skip, limit: 25)
      end

      def unpublished_for_a_generic(sub_query:, skip:0, limit: 25)
        params = { query: UNPUBLISHED_FOR_A_GENERIC % { sub_query: sub_query, skip: skip, limit: limit }}
        response = call(params: params)

        publications = process_response(response.body)

        publications.each do |pub|
          pub["owners"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.each do |pub|
          pub["contributors"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.map { |publication| Hashie::Mash.new(publication) }
      end

      def for_a_house_count(house_id:)
        for_a_generic_unpublished_count(sub_query: UNPUBLISHED_FOR_A_HOUSE_SUB_QUERY % { house_id: house_id })
      end

      def for_a_research_service_count(research_service_id:)
        for_a_generic_unpublished_count(sub_query: UNPUBLISHED_FOR_A_RESEARCH_SERVICE_SUB_QUERY % { research_service_id: research_service_id })
      end

      def for_a_section_count(section_id:)
        for_a_generic_unpublished_count(sub_query: UNPUBLISHED_FOR_A_SECTION_SUB_QUERY % { section_id: section_id })
      end

      def for_a_generic_unpublished_count(sub_query:)
        params = { query: UNPUBLISHED_COUNT_FOR_GENERIC % { sub_query: sub_query }}
        generic_count(params: params)
      end
    end
  end
end
