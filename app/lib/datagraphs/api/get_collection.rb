module Datagraphs
  module Api
    class GetCollection < CypherQuery

      QUERY = <<-Q
        MATCH (c:Collection)-[r1:hasMember]->(pw:PublicationWork)-[r2:publishedBy]->(rs:ResearchService)
        WHERE c.id="%{collection_id}"
        RETURN c.name AS collection_name,
               pw.title AS title,
               pw.id AS pw_id,
               pw.reference AS ref,
               pw.createdAt as created_at,
               rs.name AS published_by,
               rs.id AS rs_id
        ORDER BY created_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT =  <<-Q
        MATCH (c:Collection)-[r1:hasMember]->(pw:PublicationWork)
        WHERE c.id="%{collection_id}"
        RETURN COUNT(DISTINCT pw) AS total
      Q

      def process(collection_id: 'urn:publications-data:Collection:1', skip: 0, limit: 25)
        params = { query: QUERY % { collection_id: collection_id, skip: skip, limit: limit }}

        response = call(params: params)
        process_response(response.body)
      end

      def get_total(collection_id: 'urn:publications-data:Collection:1')
        params = { query: COUNT % { collection_id: collection_id }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end
    end
  end
end


