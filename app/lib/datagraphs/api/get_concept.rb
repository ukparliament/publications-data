module Datagraphs
  module Api
    class GetConcept < Base
      def process(type_or_class_name)
        @type_or_class_name = type_or_class_name
        response = call
        process_response(response.body)
      end

      def process_response(response)
        json_response = JSON.parse(response)

        normal_keys = ["label", "type", "id"]


        results = json_response["results"].each do |result|

          label = result["label"]
          datagraphs_type = result["type"]
          datagraphs_id = result["id"]

          normal_keys.each { |key| result.delete(key) }

          Concept.where(
            label: label,
            datagraphs_type: datagraphs_type,
            datagraphs_id: datagraphs_id,
            properties: result

          ).first_or_create!
        end
      end

      def url
        "#{base_url}#{project_id}/#{@type_or_class_name}"
      end
    end
  end
end
