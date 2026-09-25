module Datagraphs
  module Api
    class GetSections < CypherQuery
      QUERY = <<-Q.squish
        MATCH (s:Section)-[r1:formsPartOf]->(rs:ResearchService)
        RETURN  s.id AS id,
                s.name AS name,
                s.shortName AS short_name,
                s.strapLine AS strap_line,
                s.isDefunct AS is_defunct,
                rs.id AS research_service_id,
                rs.name as research_service_name
        ORDER BY s.isDefunct, s.name
      Q

      FOR_A_RESEARCH_SERVICE = <<-Q.squish
        MATCH (s:Section)-[r1:formsPartOf]->(rs:ResearchService)
        WHERE rs.id = '%{research_service_id}'
        AND s.isDefunct = false
        RETURN s.id AS id,
        s.name AS name,
        s.shortName AS short_name,
        s.strapLine AS strap_line
      Q

      def all
        params = { query: QUERY }
        response = call(params: params)
        body = process_response(response.body)
        body.map { |section| Hashie::Mash.new(section) }
      end

      def for_a_research_service(research_service_id)
        params = { query: FOR_A_RESEARCH_SERVICE % { research_service_id: research_service_id} }
        response = call(params: params)
        body = process_response(response.body)
        body.map { |section| Hashie::Mash.new(section) }
      end
    end
  end
end
