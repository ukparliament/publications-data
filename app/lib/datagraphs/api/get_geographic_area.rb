module Datagraphs
  module Api
    class GetGeographicArea < CypherQuery
      GEOGRAPHIC_AREA_WITH_PUBLICATION_COUNT = <<-Q.squish
        MATCH (area:GeographicArea)<-[e]-(pw:PublicationWork)
        OPTIONAL MATCH (pes:PublicationExpressionStatus)<-[r2:hasPublicationExpressionStatus]-(pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)
        WHERE pes.label = '%{publication_status_label}'
        AND area.id = '%{area_id}'
        RETURN area.id AS id,
               area.name AS label,
               count(pw) AS publication_count
      Q

      def with_id(area_id:, publication_status_label: 'Published')
        params = { query: GEOGRAPHIC_AREA_WITH_PUBLICATION_COUNT % { area_id: area_id, publication_status_label: publication_status_label }}
        response = call(params: params)
        Hashie::Mash.new(process_response(response.body).first)
      end
    end
  end
end
