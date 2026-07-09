require 'ostruct'

class SectionsController < AuthenticatedController
  include Pagy::Method

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

  def show
    redirect_to publications_section_path(params[:id])
  end

  def publications
    section_id = params[:id]
    @section = process_section

    @total_count = Datagraphs::Api::GetPublications.new.for_a_section_count(section_id: section_id)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    publications = Datagraphs::Api::GetPublications.new.for_a_section(
      section_id: section_id,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @publications = publications.map { |p| OpenStruct.new(p) }

    @page_title =  @section.name

    @crumb << { label: MAIN_PAGE_TITLE, url: sections_path }
    @crumb << { label: @page_title, url: section_path(section_id) }
    @crumb << { label: "Publications", url: nil }
  end

  private

  def process_sections
    sections = Datagraphs::Api::GetSections.new.process

    sections.map { |section| OpenStruct.new(section) }
  end

  def process_section
    section = Datagraphs::Api::GetSection.new.process(params[:id]).first

    OpenStruct.new(section)
  end
end
