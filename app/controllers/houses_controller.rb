class HousesController < ApplicationController
  before_action :set_house, only: [:show, :publications, :unpublished]
  before_action :set_research_services, only: [:show, :publications, :unpublished]

  def index
    @houses = Concept.where(datagraphs_type: "House")
    @crumb << { label: 'Houses', url: nil }
    @page_title = "Houses"
  end

  def show
    @crumb << { label: 'Houses', url: houses_path }
    @crumb << { label: @house.display_title, url: nil }
    @page_title =  @house.display_title
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

  def set_house
    @house = Concept.find_by(datagraphs_id: params[:id])
  end

  def set_research_services
    @research_services = @house.properties['hasResearchService']
  end

  def get_published_publications(research_service_datagraphs_id)
    get_publications(research_service_datagraphs_id).where("properties->>'publishedAt' IS NOT NULL")
  end

  def get_publications(research_service_datagraphs_id)
    Concept.where("properties->'publishedBy' @> :value::text::jsonb", value: research_service_datagraphs_id.to_json)
  end

  def get_unpublished_publications(research_service_datagraphs_id)
    get_publications(research_service_datagraphs_id).where("properties->>'publishedAt' IS NULL")
  end
end
