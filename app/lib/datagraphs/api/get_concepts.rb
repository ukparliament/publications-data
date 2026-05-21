module Datagraphs
  module Api
    class GetConcepts < CypherQuery

      QUERY = <<-Q
        MATCH res=(c:Concept)-[r:broaderTerm]->(broader:Concept)
        WHERE c.alphabetisationLetter = '%{letter}'
        RETURN c.id AS concept_id, c.label AS concept_name, broader.label AS broader_term
        ORDER BY c.label
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q
        MATCH res=(concept:Concept)
        WHERE concept.alphabetisationLetter = '%{letter}'
        RETURN count(res) AS total
      Q

      LETTERS = <<-Q
        MATCH res=(concept:Concept)
        RETURN COLLECT(DISTINCT concept.alphabetisationLetter) AS letters
        ORDER BY letters asc
      Q

      def get_total(letter: 'A')
        params = { query: COUNT % { letter: letter } }
        response = call(params: params)
        output = JSON.parse(response.body)
        ap output
        output["results"].first["total"]
      end

      def process(letter: "A", skip: 0, limit: 25)
        params = { query: QUERY % { skip: skip, limit: limit, letter: letter }}
        ap params
        response = call(params: params)
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
