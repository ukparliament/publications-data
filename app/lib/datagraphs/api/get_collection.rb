module Datagraphs
  module Api
    class GetCollection < CypherQuery

      QUERY = <<-Q.squish
        MATCH (c:Collection)
        OPTIONAL MATCH (c)-[r2:hasLeadMember]->(leadPublicationWork:PublicationWork)
        WHERE c.id='%{collection_id}'
        RETURN c.name AS name,
               leadPublicationWork.id AS lead_publication_work_id,
               leadPublicationWork.title AS lead_publication_work_name
      Q

      def details(collection_id: 'urn:publications-data:Collection:1')
        params = { query: QUERY % { collection_id: collection_id }}

        response = call(params: params)
        Hashie::Mash.new(process_response(response.body).first)
      end
    end
  end
end
