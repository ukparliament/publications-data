module Datagraphs
  module Api
    class GetConcept < CypherQuery
      QUERY = <<-Q.squish
        MATCH (concept:Concept)
        OPTIONAL MATCH (broaderTerm:Concept)<-[r1:broaderTerm]-(concept:Concept)
        OPTIONAL MATCH (concept:Concept)<-[r2:broaderTerm]-(narrowerTerms:Concept)
        OPTIONAL MATCH (concept)<-[s:subject]-(pw:PublicationWork)<-[r3:expressionOf]-(pe:PublicationExpression)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE concept.id = '%{concept_id}'
        AND broaderTerm.id <> '%{except_id}'
        RETURN  DISTINCT(concept.id) AS id,
                concept.label AS label,
                COUNT(DISTINCT narrowerTerms.id) AS narrower_terms_count,
                COUNT(DISTINCT pw.id) AS publications_count,
                COUNT(DISTINCT broaderTerm.id) AS broader_terms_count
                ORDER BY label ASC
        LIMIT 1
      Q

      # We don't want to go up to concept! Which is 90102
      GET_BROADER_TERMS = <<-Q.squish
        MATCH p = (broaderTerm:Concept)<-[r1:broaderTerm]-(concept:Concept)
        OPTIONAL MATCH (broaderTerm)<-[s:subject]-(pw:PublicationWork)<-[r3:expressionOf]-(pe:PublicationExpression)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE concept.id = '%{concept_id}'
        AND broaderTerm.id <> '%{except_id}'
        RETURN  DISTINCT(broaderTerm.id) AS id,
                broaderTerm.label AS label,
                COUNT(DISTINCT pw.id) AS publications_count
                ORDER BY label ASC
        OFFSET %{skip}
        LIMIT %{limit}
      Q

      GET_NARROWER_SUBJECTS = <<-Q.squish
        MATCH (c:Concept)<-[r]-(ns:Concept)
        OPTIONAL MATCH (specialism:Specialism)-[r1:specialismIn]->(ns:Concept)
        OPTIONAL MATCH (ns:Concept)<-[r2:subject]-(work:Work)
        WHERE c.id = '%{concept_id}'
        RETURN  ns.id AS id,
                ns.label AS label,
                ns.classType AS class_type,
                ns.scopeNote AS scope_note,
                ns.synonym AS synonyms,
                ns.classType AS class_type,
                COUNT(DISTINCT specialism) AS specialist_count,
                COUNT(DISTINCT work) AS publication_count
        OFFSET %{skip}
        LIMIT %{limit}
      Q

      def process(concept_id:, skip: 0, limit: 25)
        params = { query: QUERY % { skip: skip, limit: limit, concept_id: concept_id, except_id: $CONCEPT_CONCEPT_ID }}
        ap params
        response = call(params: params)
        process_response(response.body)
      end

      def and_broader_terms(concept_id:, skip: 0, limit: 25)
        params = { query: GET_BROADER_TERMS % { concept_id: concept_id, skip: 0, limit: 25, except_id: $CONCEPT_CONCEPT_ID }}
        response = call(params: params)
        process_response(response.body)
      end

      def and_narrower_subjects(concept_id:, skip: 0, limit: 25)
        params = { query: GET_NARROWER_SUBJECTS % { concept_id: concept_id, skip: 0, limit: 25 }}
        response = call(params: params)
        process_response(response.body)
      end

    end
  end
end
