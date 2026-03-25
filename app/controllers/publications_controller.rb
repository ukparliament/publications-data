class PublicationsController < ApplicationController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Published publications'

  def index
    @total_count = Datagraphs::Api::GetPublications.new.get_total

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    publications = Datagraphs::Api::GetPublications.new.process(
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @publications = publications.map { |pub| OpenStruct.new(pub) }

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show

    publication_expressions = Datagraphs::Api::GetPublication.new.process(params[:id] )
    @publication_expressions = publication_expressions.map { |pub| OpenStruct.new(pub) }

    title = @publication_expressions.first ? @publication_expressions.first.title : ''

    # These are on the work
    first = @publication_expressions.first

    @reference = first.reference
    @teaser_text = first.teaser_text
    @research_service_name = first.research_service_name
    @research_service_id = first.research_service_id

    @publication_expressions.each do |publication_expression|
      publication_expression["people"] = publication_expression["people_ids"].zip(publication_expression["people_names"]).zip(publication_expression["contribution_types"])
   #   publication_expression["contribution_types"] = publication_expression["people_ids"].zip(publication_expression["people_names"])
    end



    @crumb << { label: MAIN_PAGE_TITLE, url: houses_path }
    @crumb << { label: title, url: nil }
    @page_title =  title
  end
end
