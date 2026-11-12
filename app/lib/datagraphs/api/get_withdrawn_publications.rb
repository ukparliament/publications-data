module Datagraphs
  module Api
    class GetWithdrawnPublications < CypherQuery
      ALL = <<-Q
      MATCH (pw:PublicationWork)-[:hasWithdrawalPeriod]->(wp:WithdrawalPeriod)
      RETURN pw, wp, COUNT(wp.reinstatedAt) AS reinstated
      NEXT YIELD pw, wp, reinstated
      FILTER reinstated = 0
      MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs:ResearchService)
      MATCH (pe)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
      OPTIONAL MATCH (person:Person)<-[r4:contributionBy]-(cont:Contribution)-[r5:contributionTo]->(pe)
      WHERE pes.label = "Published"
      RETURN
            wp.withdrawnAt AS withdrawn_at,
            pe.id as publication_expression_id,
            pw.id as publication_work_id,
            pw.title as title,
            pes.label as status,
            pe.publishedAt as published_at,
            pw.createdOn as created_at,
            pe.number as version_number,
            pe.updatedAt AS updated_at,
            rs.shortName AS short_research_service_name,
            rs.id AS research_service_id,
            COLLECT_LIST(DISTINCT person.id) AS contributor_ids,
            COLLECT_LIST(DISTINCT person.displayName) AS contributor_names
      ORDER BY pe.publishedAt desc
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q
        MATCH (pw:PublicationWork)-[:hasWithdrawalPeriod]->(wp:WithdrawalPeriod)
        RETURN pw, wp, COUNT(wp.reinstatedAt) AS reinstated
        NEXT YIELD pw, wp, reinstated
        FILTER reinstated = 0
        RETURN COUNT(DISTINCT pw) AS total
      Q

      def total
        params = { query: COUNT }
        generic_count(params: params)
      end

      def all(skip: 0, limit: 25)
        params = { query: ALL % { skip: skip, limit: limit }}
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
    end
  end
end
