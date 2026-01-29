module Datagraphs
  module Api
    class SearchForConcepts < Base

      PaginationResults = Data.define(:total_results, :next_page_token, :previous_page_token, :took)

      def process(dataset_label = "specialisms")
        @dataset_label = dataset_label
        @total_count = 0

        response = call(params: default_query_params)
        pagination_response = process_response(response.body)

        if pagination_response
          total_results = pagination_response.total_results

          ap "First call, total results: #{total_results}"

          while @total_count < total_results
            ap "In loop"
            params = default_query_params.merge({ nextPageToken: pagination_response.next_page_token })

            response = call(params: params)
            pagination_response = process_response(response.body)
          end
        end
      end

      def default_query_params
        {
          pageSize: 500
        }
      end

      def process_response(response)
        json_response = JSON.parse(response)

        normal_keys = ["label", "type", "id"]

        results = json_response["results"]

        if results
          results.each do |result|

            # We are going to save any other attributes as properties, so we
            # pull these out and then we don't duplicate them as properties
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

          @total_count = @total_count + results.size

          pagination_response = json_response["search"]

          @total_count = @total_count + results.size

          ap pagination_response

          PaginationResults.new(
            total_results: pagination_response["totalResults"],
            next_page_token: pagination_response["nextPageToken"],
            previous_page_token: pagination_response["previousPageToken"],
            took: pagination_response["took"]
          )
        end
      end

      def url
        "#{base_url}#{project_id}/#{@dataset_label}"
      end
    end
  end
end
