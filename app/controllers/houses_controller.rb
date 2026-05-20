class HousesController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Houses'

  def index
    @houses = process_houses

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    house_id = params[:id]

    @total_count = Datagraphs::Api::GetHouse.new.house_with_publications_with_a_status_count


    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @house = process_house(house_id)
    @publications = process_publications(house_id: house_id, skip: @pagy.offset,
    limit: @pagy.limit)

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

  def process_house(house_id)
    house = Datagraphs::Api::GetHouse.new.process(house_id).first

    house["research_services"] = house["research_service_ids"].zip(house["research_service_names"])

    OpenStruct.new(house)
  end

  def process_publications(house_id:, skip:, limit:)
    publications = Datagraphs::Api::GetHouse.new.house_with_publications_with_a_status(house_id: house_id, publication_status_label: "Published", skip: skip, limit: limit)

    publications.map { |publication| OpenStruct.new(publication) }
  end
end
