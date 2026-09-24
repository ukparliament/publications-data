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

    ap @geographic_area
    @page_title =  @geographic_area.label

    @crumb << { label: MAIN_PAGE_TITLE, url: geographic_areas_path }
    @crumb << { label: @page_title, url: nil }
  end
end
