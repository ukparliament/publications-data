require 'ostruct'

class ExpressionsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Publication expressions'

  def index
    @publication_work_id = params[:publication_id]
    @statuses = Datagraphs::Api::GetExpressions.new.get_statuses(publication_work_id: @publication_work_id).first["statuses"]
    @selected_statuses = params["statuses"]

    if @selected_statuses.blank?
      @selected_statuses = @statuses
    end

    filter = @selected_statuses.map { |s| "pes.label = '#{s}'" }.join(" OR ")
    @total_count = Datagraphs::Api::GetExpressions.new.get_dynamic_status_count(publication_work_id: @publication_work_id, statuses: filter)

    publication = Datagraphs::Api::GetPublication.new.details(publication_work_id: @publication_work_id).first
    @publication = OpenStruct.new(publication)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    expressions  = Datagraphs::Api::GetExpressions.new.dynamic_expressions(
      publication_work_id: @publication_work_id,
      skip: @pagy.offset,
      limit: @pagy.limit,
      statuses: filter
    )

    expressions.each do |expression|
      expression["contributions"] = expression["people_ids"].zip(expression["people_names"]).zip(expression["contribution_types"]).zip(expression["public"]).zip(expression["ordinalities"])
    end

    @expressions = expressions.map { |expression| OpenStruct.new(expression) }

    @page_title = @publication.title == 'Untitled' ? @expressions.first.title : @publication.title

    @crumb << { label: "Publications", url: publications_path }
    @crumb << { label: @page_title, url: publication_path(@publication.id) }
    @crumb << { label: "Expressions", url: nil }

  end

  def show
    expression = Datagraphs::Api::GetExpression.new.process(expression_id: params[:id]).first
    @expression = OpenStruct.new(expression)

    resources = Datagraphs::Api::GetExpression.new.resources(expression_id: params[:id])
    @resources = resources.map { |resource| OpenStruct.new(resource) if resource["id"] }

    related_links = Datagraphs::Api::GetExpression.new.related_links(expression_id: params[:id])
    @related_links = related_links.map { |related_link| OpenStruct.new(related_link) if related_link["id"] }

    contributors = Datagraphs::Api::GetExpression.new.contributors(expression_id: params[:id])
    @contributors = contributors.map { |contributor| OpenStruct.new(contributor) if contributor["person_id"] }

    sections = Datagraphs::Api::GetExpression.new.sections(expression_id: params[:id])
    @sections = sections.map { |section| OpenStruct.new(section) if section["name"] }

    title = @expression.title

    @crumb << { label: "Published publications", url: publications_path }
    @crumb << { label: @expression.title, url: publications_path(@expression.publication_work_id) }
    @crumb << { label: "Expressions", url: publication_expressions_path(@expression.publication_work_id) }

    @crumb << { label: helpers.nice_date_time(@expression.published_at), url: nil }

    @page_title =  title
  end
end
