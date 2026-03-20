class ResearchServicesController < ApplicationController

  def index
    @research_services = process_research_services

    ap @research_services

    @crumb << { label: 'Research services', url: nil }
    @page_title = "Research services"
  end

  def show
    @research_service = process_research_service

    @page_title =  @research_service.name

    @crumb << { label: 'Research services', url: houses_path }
    @crumb << { label: @page_title, url: nil }
  end

  private

  def process_research_services
    research_services = Datagraphs::Api::GetResearchServices.new.process

    research_services.each do |rs|
      rs["houses"] = rs["house_ids"].zip(rs["house_names"])
    end

    research_services.map { |research_service| OpenStruct.new(research_service) }
  end

  def process_research_service
    research_service = Datagraphs::Api::GetResearchService.new.process(params[:id]).first

    research_service["houses"] = research_service["house_ids"].zip(research_service["house_names"])

    OpenStruct.new(research_service)
  end
end
