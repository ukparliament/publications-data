module Datagraphs
  module Api
    class GetDatasets < Base
      def process
        # Note - this is a subclass, call can be found in the super class Base
        response = call
        process_response(response.body)
      end

      def process_response(response)
        json_response = JSON.parse(response)

        json_response["results"].each do |result|
          Dataset.where(
            name: result["name"],
            namespace: result["namespace"],
            is_private: result["isPrivate"],
            datagraphs_id: result["id"],
            total_concepts: result["totalConcepts"],
            concept_types: result["conceptTypes"],
            link_to_self: result["_links"]["_self"]
          ).first_or_create!
        end
      end

      def url
        "#{base_url}#{project_id}"
      end

      def project_id
        $PROJECT_ID
      end
    end
  end
end
