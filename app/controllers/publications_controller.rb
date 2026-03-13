class PublicationsController < ApplicationController
  include Pagy::Method

  def index
    # @publications = get_publications

    @pagy, @publications = pagy(:offset, get_publications) # :offset paginator

    @crumb << { label: 'Publications', url: nil }
    @page_title = "Publications"
  end

  def show
    @publication = PublicationExpression.find_by(datagraphs_id: params[:id])
    @publication_work = PublicationWork.find_by(datagraphs_id: @publication.expression_of)



    @contributions = @publication.contributions

    @crumb << { label: 'Publications', url: houses_path }
    @crumb << { label: @publication.display_title, url: nil }
    @page_title =  @publication.display_title
  end

  # Published
  def publications
    research_service_datagraphs_id = @research_services.first

    @publications = get_published_publications(research_service_datagraphs_id)

    @crumb << { label: 'Houses', url: houses_path }
    @crumb << { label: @house.display_title, url: house_path }
    @crumb << { label: 'Publications', url: nil }

    @page_title =  "#{@house.display_title} publications"
  end

  def unpublished
    research_service_datagraphs_id = @research_services.first

    @publications = get_unpublished_publications(research_service_datagraphs_id)

    @crumb << { label: 'Houses', url: houses_path }
    @crumb << { label: @house.display_title, url: house_path }
    @crumb << { label: 'Publications', url: publications_house_path }
    @crumb << { label: 'Unpublished', url: nil }

    @page_title =  "Unpublished #{@house.display_title} publications"
  end

  private

  def get_published_publications
    get_publications.where("properties->>'publishedAt' IS NOT NULL")
  end

  def get_publications
    PublicationExpression.order(Arel.sql("properties->>'createdAt' DESC"))
  end

  def get_unpublished_publications(research_service_datagraphs_id)
    get_publications.where("properties->>'publishedAt' IS NULL")
  end
end
