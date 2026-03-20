class HousesController < ApplicationController
  # before_action :set_house, only: [:show, :publications, :unpublished]
  # before_action :set_research_services, only: [:show, :publications, :unpublished]

  def index
    @houses = process_houses

    @crumb << { label: 'Houses', url: nil }
    @page_title = "Houses"
  end

  def show
    @house = process_house

    @page_title =  @house.name

    @crumb << { label: 'Houses', url: houses_path }
    @crumb << { label: @page_title, url: nil }
  end

  # Published
  # def publications
  #   @publications = @research_services.map do |research_service_datagraphs_id|
  #     get_published_publications(research_service_datagraphs_id)
  #   end.flatten

  #   @crumb << { label: 'Houses', url: houses_path }
  #   @crumb << { label: @house.display_title, url: house_path }
  #   @crumb << { label: 'Publications', url: nil }

  #   @page_title =  "#{@house.display_title} publications"
  # end

  # def unpublished
  #   @publications = @research_services.map do |research_service_datagraphs_id|
  #     get_unpublished_publications(research_service_datagraphs_id)
  #   end.flatten

  #   @crumb << { label: 'Houses', url: houses_path }
  #   @crumb << { label: @house.display_title, url: house_path }
  #   @crumb << { label: 'Publications', url: publications_house_path }
  #   @crumb << { label: 'Unpublished', url: nil }

  #   @page_title =  "Unpublished #{@house.display_title} publications"
  # end

  private

  def process_houses
    houses = Datagraphs::Api::GetHouses.new.process

    houses.each do |house|
      house["research_services"] = house["research_service_ids"].zip(house["research_service_names"])
    end

    houses.map { |house| OpenStruct.new(house) }
  end

  def process_house
    house = Datagraphs::Api::GetHouse.new.process(params[:id]).first

    house["research_services"] = house["research_service_ids"].zip(house["research_service_names"])

    OpenStruct.new(house)
  end

  # def set_house
  #   @house = Concept.find_by(datagraphs_id: params[:id])
  # end

  # def set_research_services
  #   @research_services = @house.properties['hasResearchService']
  # end

  # def get_published_publications(research_service_datagraphs_id)
  #   get_publications(research_service_datagraphs_id).where("properties->>'publishedAt' IS NOT NULL")
  # end

  # def get_publications(research_service_datagraphs_id)
  #   Concept.where("properties->'publishedBy' @> :value::text::jsonb", value: research_service_datagraphs_id.to_json)
  # end

  # def get_unpublished_publications(research_service_datagraphs_id)
  #   get_publications(research_service_datagraphs_id).where("properties->>'publishedAt' IS NULL")
  # end
end
