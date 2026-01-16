module Datagraphs
  module Api
    class GetDatasets < Base
      def process
        response = call
        process_response(response.body)
      end

      def process_response(response)
        json_response = JSON.parse(response)

        results = json_response["results"].each do |result|
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

        ap Dataset.all

      end

      def url
        "#{base_url}#{project_id}"
      end

      def project_id
        "subject-specialist-finder"
      end
    end
  end
end
