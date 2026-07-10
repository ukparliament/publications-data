module Datagraphs
  module Api
    class GetConcepts < CypherQuery

      QUERY = <<-Q.squish
        MATCH p = (broaderTerms:Concept)<-[r1:broaderTerm]-(concept:Concept)<-[r2:broaderTerm]-(narrowerTerms:Concept)
        MATCH (concept)<-[s:subject]-(pw:PublicationWork)<-[r3:expressionOf]-(pe:PublicationExpression)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE concept.alphabetisationLetter = '%{letter}'
        RETURN  DISTINCT(concept.id) AS id,
                concept.label AS concept_name,
                COUNT(DISTINCT narrowerTerms.id) AS narrower_terms_count,
                COUNT(DISTINCT pw.id) AS publications_count,
                COUNT(DISTINCT broaderTerms.id) AS broader_terms_count
                ORDER BY concept_name ASC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      CHILD_QUERY = <<-Q.squish
        MATCH path0 = (parent:Concept)<-[r:broaderTerm]-(child:Concept)
        MATCH path1 = (child)<-[s:subject]-(pw:PublicationWork)
        WHERE parent.label = "%{broader_term}"
        RETURN child.label AS name,
               child.id AS id,
               COUNT(DISTINCT pw.id) AS publication_count
        ORDER BY name
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q.squish
        MATCH p = (a:Concept)<-[e:broaderTerm]-(b:Concept)
        WHERE a.alphabetisationLetter = '%{letter}'
        RETURN count(a) AS total
      Q

      LETTERS = <<-Q.squish
        MATCH p = (a:Concept)<-[e:broaderTerm]-(b:Concept)
        RETURN COLLECT(DISTINCT a.alphabetisationLetter) AS letters
        ORDER BY letters asc
      Q

      def get_concepts_based_on_broader_term(broader_term: 'Concept', skip: 0, limit: 200)
        params = { query: CHILD_QUERY % { broader_term: broader_term, skip: skip, limit: limit }}
        ap params
        response = call(params: params)
        process_response(response.body)
      end

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
