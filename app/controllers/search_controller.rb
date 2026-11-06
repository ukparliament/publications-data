class SearchController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = "Search"

  # A method to return the HTML necessary for the search autocomplete function.
  def autocomplete
    # We get the query from the URL parameter.
    @query = params[:q]

    @published_by = Datagraphs::Api::GetResearchServices.new.all
    @selected_published_by_ids = @published_by.map(&:id)

    # We query Data Graphs with the query, returning only people and concepts - not publications.
    search_service = Datagraphs::Api::Search.new
    search_service.process(query: @query, published_by_ids: nil)

    # We set the results to be the first item returned.
    results = search_service.results.first

    # For each result ...
    @results = results.map do |result|
      # ... we construct a new object.
      result["display_title"] = result["label"] || result["title"] || result["name"]
      Hashie::Mash.new(result)
    end

    # We render the results.
    render "search/_autocomplete_search_results", locals: { results: @results }, layout: false
  end

  # A method to render the search results page.
  def index
    # We get the query from the URL parameter.
    @query = params[:button_query] || params[:search][:query]

    @published_by = Datagraphs::Api::GetResearchServices.new.all
    @published_by_ids = @published_by.map(&:id)

    # We get the selected types from the URL parameters.
    @selected_published_by_ids = params[:research_service_ids] || @published_by_ids

    # If a query has been passed ...
    if @query.present?

      page_number = params[:page] || 1
      page_size = 25

      # ... we query Data Graphs with the query.
      search_service = Datagraphs::Api::Search.new
      results = search_service.pagination_process(query: @query, page_size: page_size, page_number: page_number, published_by_ids: @selected_published_by_ids)

      # We set the total count.
      @total_count = results.total_count

      # We set up the pagination.
      @pagy, _ = pagy( :offset, [], count: @total_count, page: page_number, limit: page_size )

      # We create the results object.
      @results = results.results.map { |result| Hashie::Mash.new(result) }
    # Otherwise, if no query has been passed ...
    else

      # ... we set the results to an empty array.
      @results = []

      # We set the total count to 0
      @total_count = 0
    end

    # We set the page meta information.
    if @query.blank?
      @page_title = "No search query sent"
      @description = "No search query sent."
    else
      @page_title = "Search for '#{@query}'"
      @multiline_page_title = "Search for <span class='subhead'>'#{@query}'</span>".html_safe
    end
    @crumb << {label: "Search for '#{@query}'", url: nil}
  end
end
