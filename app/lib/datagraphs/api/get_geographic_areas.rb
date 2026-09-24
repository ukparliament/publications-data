module Datagraphs
  module Api
    class GetGeographicAreas < CypherQuery

      ALL_GEOGRAPHIC_AREAS_WITH_PUBLICATION_COUNT = <<-Q.squish
        MATCH (area:GeographicArea)<-[e]-(pw:PublicationWork)
        OPTIONAL MATCH (pes:PublicationExpressionStatus)<-[r2:hasPublicationExpressionStatus]-(pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)
        WHERE pes.label = 'Published'
        RETURN area.id AS id,
               area.name AS label,
               count(pw) AS publication_count
      Q

      def all
        params = { query: ALL_GEOGRAPHIC_AREAS_WITH_PUBLICATION_COUNT }
        response = call(params: params)
        process_response(response.body).map { |result| Hashie::Mash.new(result) }
      end
    end
  end
end
