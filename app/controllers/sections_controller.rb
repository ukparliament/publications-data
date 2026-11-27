class SectionsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Sections'

  def index
    @sections = Datagraphs::Api::GetSections.new.all

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    redirect_to publications_section_path(params[:id])
  end

  def publications
    section_id = params[:id]
    @section = Datagraphs::Api::GetSection.new.process(params[:id])

    get_publications = Datagraphs::Api::GetPublications.new

    @total_count = get_publications.for_a_section_count(section_id: section_id)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @publications = get_publications.for_a_section(section_id: section_id, skip: @pagy.offset, limit: @pagy.limit)

    @page_title =  @section.name

    @crumb << { label: MAIN_PAGE_TITLE, url: sections_path }
    @crumb << { label: @page_title, url: section_path(section_id) }
    @crumb << { label: "Publications", url: nil }
  end

  def unpublished
    section_id = params[:id]
    @section = Datagraphs::Api::GetSection.new.process(section_id)

    get_unpublished_publications = Datagraphs::Api::GetUnpublishedPublications.new

    @total_count = get_unpublished_publications.for_a_section_count(section_id: section_id)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @publications = get_unpublished_publications.for_a_section(
      section_id: section_id,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @page_title =  @section.name

    @crumb << { label: MAIN_PAGE_TITLE, url: sections_path }
    @crumb << { label: @page_title, url: section_path(section_id) }
    @crumb << { label: "Unpublished", url: nil }
  end
end
