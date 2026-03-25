module Datagraphs
  module Api
    class GetPeople < CypherQuery

      QUERY = <<-Q
        MATCH (p:Person)
        RETURN p.id AS id, p.name AS name
        ORDER BY p.name asc
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q
        MATCH (p:Person)
        RETURN count(p) AS total
      Q

      def get_total
        params = { query: COUNT }
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def process(skip: 0, limit: 25)
        params = { query: QUERY % { skip: skip, limit: limit }}
        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
