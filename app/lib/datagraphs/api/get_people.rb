module Datagraphs
  module Api
    class GetPeople < CypherQuery


      QUERY = <<-Q
        MATCH path_1 = (p:Person)
        OPTIONAL MATCH path_2 = (p)<-[e:contributionBy]-(c:Contribution)-[r:contributionTo]->(pe:PublicationExpression)-[s:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label = "Published"
        AND p.alphabetisationLetter = '%{letter}'
        RETURN p.displayName AS name,
               p.id AS id,
               COUNT(DISTINCT pe.id) AS number_of_contributions, -- Note that a person may have multiple contributions to a publication, this ensures it is publications we count rather than as owner (1) and author (2)
               p.sortName as sort_name
        ORDER BY sort_name ASC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q
        MATCH (p:Person)
        WHERE p.alphabetisationLetter = '%{letter}'
        RETURN count(p) AS total
      Q

      LETTERS = <<-Q
        MATCH res=(p:Person)
        RETURN COLLECT(DISTINCT p.alphabetisationLetter) AS letters
        ORDER BY letters asc
      Q

      def get_total(letter: 'A')
        params = { query: COUNT % { letter: letter } }
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def process(letter: "A", skip: 0, limit: 25)
        params = { query: QUERY % { skip: skip, limit: limit, letter: letter }}
        ap params
        response = call(params: params)
        ap "HI"
        ap response.body
        ap "THERE"
        process_response(response.body)
      end

      def get_letters
        params = { query: LETTERS }
        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end
