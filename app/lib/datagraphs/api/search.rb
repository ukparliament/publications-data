module Datagraphs
  module Api
    class Search < Base
      attr_reader :results

      # This is a simple data model to help us with pagination
      PaginationResults = Data.define(:total_results, :next_page_token, :previous_page_token, :took)
      NewPaginationResults = Data.define(:total_count, :results)

      STANDARD_KEYS = ["label", "type", "id"].freeze
      TYPES = ["PublicationWork"].freeze

      def pagination_process(query:, published_by_ids:, page_size: 10, page_number: 1)

        params = default_query_params_for_pagination(query: query, published_by: convert_published_by_ids(published_by_ids), page_number: page_number, page_size: page_size)
        response = call(params: params)

        json_response = JSON.parse(response.body)
        NewPaginationResults.new(total_count: json_response["search"]["totalResults"], results: json_response["results"])
      end

      def process(query:, published_by_ids:)
        @total_count = 0
        @results = []

        published_by_query = convert_published_by_ids(published_by_ids)

        response = call(params: default_query_params(query: query, published_by: published_by_query))
        pagination_response = process_response(response.body)

        return unless pagination_response

        total_results = pagination_response.total_results

        logger.debug "First call, total results: #{total_results}"

        while @total_count < total_results
          # query is the thing we're searching for
          params = default_query_params(query: query).merge({nextPageToken: pagination_response.next_page_token})

          response = call(params: params)
          pagination_response = process_response(response.body)
        end
      end

      def convert_published_by_ids(published_by_ids)
        return nil unless published_by_ids

        published_by_ids.map do |published_by_id|
          "publishedBy:#{published_by_id}"
        end.join("|")
      end

      def default_query_params_for_pagination(query:, published_by:, page_size: 10, page_number: 1)
        {
          pageSize: page_size,
          pageNo: page_number,
          filter: filter(published_by),
          fields: fields,
          q: query,
          embed: "publishedBy"
        }
      end

      # In the DL app this uses these fields
      # fields:"id,type,label,title,name,alternativeName,summary,scopeNote,publishedURL,publicationDate,author,teaserSummary,inSection.label,isHeadOfSection,isCurrentlyAvailable",
      def default_query_params(query:, published_by:)
        {
          pageSize: 500,
          filter: filter(published_by),
          fields: fields,
          q: query,
          embed: "publishedBy"
        }
      end

      def filter(published_by)
        "type:PublicationWork,type:-PublicationExpression,type:-Concept,type:-Section,type:-House,type:-ResearchService,(#{published_by})"
      end

      def fields
        "type,title,createdOn,reference,publishedBy.id, publishedBy.name"
      end

      def process_response(response)
        json_response = JSON.parse(response)

        results = json_response["results"]

        return unless results

        @results << results
        @total_count += results.size

        pagination_response = json_response["search"]

        @total_count += results.size

        PaginationResults.new(
          total_results: pagination_response["totalResults"],
          next_page_token: pagination_response["nextPageToken"],
          previous_page_token: pagination_response["previousPageToken"],
          took: pagination_response["took"]
        )
      end

      def url
        "#{base_url}#{project_id}/_all"
      end
    end
  end
end
