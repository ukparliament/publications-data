require 'ostruct'

class ResearchServicesController < AuthenticatedController
  include Pagy::Method

  def index
    @research_services = process_research_services

    @crumb << { label: 'Research services', url: nil }
    @page_title = "Research services"
  end

  def show
    research_service_id = params[:id]
    @research_service = process_research_service(research_service_id)

    @publications = get_publications(research_service_id)

    @page_title =  @research_service.name

    @crumb << { label: 'Research services', url: research_services_path }
    @crumb << { label: @page_title, url: nil }
  end

  private

  def get_publications(research_service_id)
    @total_count = Datagraphs::Api::GetPublications.new.get_count_for_a_research_service(research_service_id)

    ap "HI"
    ap @total_count
    ap "THERE"

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    publications = Datagraphs::Api::GetPublications.new.get_for_a_research_service(
      research_service_id: research_service_id,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @publications = publications.map { |pub| OpenStruct.new(pub) }
  end

  def process_research_services
    research_services = Datagraphs::Api::GetResearchServices.new.process

    research_services.each do |rs|
      rs["houses"] = rs["house_ids"].zip(rs["house_names"])
    end

    research_services.map { |research_service| OpenStruct.new(research_service) }
  end

  def process_research_service(research_service_id)
    research_service = Datagraphs::Api::GetResearchService.new.process(research_service_id).first

    research_service["houses"] = research_service["house_ids"].zip(research_service["house_names"])

    OpenStruct.new(research_service)
  end
end
