module Datagraphs
  module Api
    class GetCollections < CypherQuery

      QUERY = <<-Q
        MATCH (c:Collection)-[r1:hasMember]->(pw:PublicationWork)
        RETURN c.name AS name, count(pw) AS pw_count, c AS collection
      Q

      def process
        params = { query: QUERY }
        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
