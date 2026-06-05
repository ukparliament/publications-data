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

    @expressions = expressions.map { |expression| OpenStruct.new(expression) }
    @expressions.each do |expression|
      expression["people"] = expression["people_ids"].zip(expression["people_names"]).zip(expression["contribution_types"])
    end

    @crumb << { label: "Publications", url: publications_path }
    @crumb << { label: @publication.title, url: publication_path(@publication.id) }
    @crumb << { label: "Expressions", url: nil }
    @page_title = @publication.title
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

    title = @expression.title

    @crumb << { label: "Published publications", url: publications_path }
    @crumb << { label: @expression.title, url: publications_path(@expression.publication_work_id) }
    @crumb << { label: "Expressions", url: publication_expressions_path(@expression.publication_work_id) }

    @crumb << { label: helpers.nice_date_time(@expression.published_at), url: nil }

    @page_title =  title
  end
end
