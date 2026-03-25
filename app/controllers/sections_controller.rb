class SectionsController < ApplicationController

  MAIN_PAGE_TITLE = 'Sections'

  def index
    @sections = process_sections

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    @section = process_section

    @page_title =  @section.name

    @crumb << { label: MAIN_PAGE_TITLE, url: sections_path }
    @crumb << { label: @page_title, url: nil }
  end

  private

  def process_sections
    sections = Datagraphs::Api::GetSections.new.process

    # sections.each do |section|
    #   section["research_services"] = section["research_service_ids"].zip(section["research_service_names"])
    # end

    sections.map { |section| OpenStruct.new(section) }
  end

  def process_section
    section = Datagraphs::Api::GetSection.new.process(params[:id]).first

    OpenStruct.new(section)
  end
end




 #{"results":[{"s":{"id":"urn:publications-data:Section:16849","type":"Section","name":"Business and Transport Section","shortName":"BTS","strapLine":"The Business and Transport Section covers topics including transport, pensions, taxation, financial systems and institutions, corporate matters, and employment.","isDefunct":false,"formsPartOf":"urn:publications-data:ResearchService:1"}},{"s":{"id":"urn:publications-data:Section:17113","type":"Section","name":"Economic Policy and Statistics Section","shortName":"EPAS","strapLine":"The Economic Policy and Statistics Section covers policy on topics including the economy, trade and public spending, as well as statistics on a wider range of policy areas, including businesses, employment and poverty.","isDefunct":false,"formsPartOf":"urn:publications-data:ResearchService:1"}},{"s":{"id":"urn:publications-data:Section:25036","type":"Section","name":"Home Affairs Section","shortName":"HAS","strapLine":"The Home Affairs Section covers topics including policing and criminal justice, immigration, civil law, national security, media, equality and human rights.","isDefunct":false,"formsPartOf":"urn:publications-data:ResearchService:1"}},{"s":{"id":"urn:publications-data:Section:298694",       ORDER BY section.name
