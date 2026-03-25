class HousesController < AuthenticatedController

  MAIN_PAGE_TITLE = 'Houses'

  def index
    @houses = process_houses

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    @house = process_house

    @page_title =  @house.name

    @crumb << { label: MAIN_PAGE_TITLE, url: houses_path }
    @crumb << { label: @page_title, url: nil }
  end

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
end
