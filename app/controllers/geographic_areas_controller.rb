class GeographicAreasController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Geographic areas'

  def index
    @geographic_areas = Datagraphs::Api::GetGeographicAreas.new.all

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    area_id = params[:id]
    @geographic_area = Datagraphs::Api::GetGeographicArea.new.with_id(area_id: area_id)


    @total_count = Datagraphs::Api::GetPublications.new.for_a_geographic_area_count(geographic_area_id: area_id)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)
    @publications = Datagraphs::Api::GetPublications.new.for_a_geographic_area(geographic_area_id: area_id, skip: @pagy.offset, limit: @pagy.limit)

    @page_title =  @geographic_area.label

    @crumb << { label: MAIN_PAGE_TITLE, url: geographic_areas_path }
    @crumb << { label: @page_title, url: nil }
  end
end
