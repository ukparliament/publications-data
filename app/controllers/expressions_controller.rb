require 'ostruct'

class ExpressionsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Publication expressions'

  def index

    publication = Datagraphs::Api::GetPublication.new.get_published_publication_details.first
    @publication = OpenStruct.new(publication)

    @total_count = Datagraphs::Api::GetExpressions.new.get_total
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    expressions = Datagraphs::Api::GetExpressions.new.process(
      skip: @pagy.offset,
      limit: @pagy.limit
    )

#<OpenStruct title="Service industries: Economic indicators", teaser_text="The service industries include retail, finance, administration, and other areas. Find the latest data on the activity of the UK services sector.", id="urn:publications-data:PublicationExpression:69399", status="Published", ref="SN02786", research_service_id="urn:publications-data:ResearchService:1", research_service_name="House of Commons Library", created_at="2025-09-23T14:24:03.000Z", published_at="2026-02-12T10:00:30.000Z">

    @expressions = expressions.map { |expression| OpenStruct.new(expression) }

    @crumb << { label: "Publications", url: publications_path }
    @crumb << { label: @publication.title, url: publication_path(@publication.id) }
    @crumb << { label: "Expressions", url: nil }
    @page_title = @publication.title


  end

  def show
    @publication_work_id = params[:id]
    @total_count = Datagraphs::Api::GetPublication.new.get_total(publication_work_id: @publication_work_id)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    publication_expressions = Datagraphs::Api::GetPublication.new.process(
      publication_work_id: params[:id],
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @publication_expressions = publication_expressions.map { |pub| OpenStruct.new(pub) }

    title = @publication_expressions.first ? @publication_expressions.first.title : ''

    # These are on the work
    first = @publication_expressions.first

    @reference = first.ref
    @teaser_text = first.teaser_text
    @research_service_name = first.research_service_name
    @research_service_id = first.research_service_id

    @publication_expressions.each do |publication_expression|
      publication_expression["people"] = publication_expression["people_ids"].zip(publication_expression["people_names"]).zip(publication_expression["contribution_types"])
   #   publication_expression["contribution_types"] = publication_expression["people_ids"].zip(publication_expression["people_names"])
    end

    @contributors = Datagraphs::Api::GetPublication.new.get_contributors(publication_work_id: @publication_work_id).uniq

    resources = Datagraphs::Api::GetPublication.new.get_resources(publication_work_id: @publication_work_id)
    @resources = resources.map { |resource| OpenStruct.new(resource) if resource["file_title"].present? }

    @people_with_roles = @publication_expressions.map { |pe| pe["people"] }

    @crumb << { label: MAIN_PAGE_TITLE, url: publications_path }
    @crumb << { label: title, url: nil }
    @page_title =  title
  end
end
