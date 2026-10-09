module Datagraphs
  module Api
    class GetCollections < CypherQuery
      QUERY = <<-Q.squish
        MATCH (c:Collection)-[r1:hasMember]->(pw:PublicationWork)
        OPTIONAL MATCH (c)-[r2:hasLeadMember]->(leadPublicationWork:PublicationWork)
        MATCH (pe:PublicationExpression)-[r3:expressionOf]->(pw:PublicationWork)-[r4:publishedBy]->(rs:ResearchService)
        MATCH (pe)-[r7:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH (person:Person)<-[r5:contributionBy]-(cont:Contribution)-[r6:contributionTo]->(pe)
        WHERE pes.label = 'Published'
        RETURN c.name AS name,
               c.id AS id,
               leadPublicationWork.id AS lead_publication_work_id,
               leadPublicationWork.title AS lead_publication_work_name,
               COUNT(pw) AS pw_count
        ORDER BY name
      Q

      def all
        params = { query: QUERY }
        response = call(params: params)
        body = process_response(response.body)

        body.map { |record| Hashie::Mash.new(record) }
      end
    end
  end
end
