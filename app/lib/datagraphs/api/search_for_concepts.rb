module Datagraphs
  module Api
    class SearchForConcepts < Base

      # This is a simple data model to help us with pagination
      PaginationResults = Data.define(:total_results, :next_page_token, :previous_page_token, :took)

      STANDARD_KEYS = ["label", "type", "id"]

      def process(dataset_label = "specialisms")
        @dataset_label = dataset_label
        @total_count = 0

        response = call(params: default_query_params)
        pagination_response = process_response(response.body)

        if pagination_response
          total_results = pagination_response.total_results

          logger.debug "First call, total results: #{total_results}"

          while @total_count < total_results
            logger.debug "In loop"
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

        results = json_response["results"]

        if results
          results.each { |result| process_single_record(single_record) }

          @total_count = @total_count + results.size

          pagination_response = json_response["search"]

          @total_count = @total_count + results.size

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

      def process_single_record(single_record)
        # We are going to save any other attributes as properties, so we
        # pull these out and then we don't duplicate them as properties
        label = single_record["label"]
        datagraphs_type = single_record["type"]
        datagraphs_id = single_record["id"]

        STANDARD_KEYS.each { |key| single_record.delete(key) }

        #ap datagraphs_type

        Concept.where(
          label: label,
          datagraphs_type: datagraphs_type,
          datagraphs_id: datagraphs_id,
          properties: single_record

        ).first_or_create!
      end
    end
  end
end
