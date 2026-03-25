require 'ostruct'

class PeopleController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'People'

  def index
    @total_count = Datagraphs::Api::GetPeople.new.get_total

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    people = Datagraphs::Api::GetPeople.new.process(
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @people = people.map { |p| OpenStruct.new(p) }

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    publications = Datagraphs::Api::GetPublicationDataForAPerson.new.process(params[:id])
    @publications = publications.map { |pub| OpenStruct.new(pub) }
    @person_name = @publications.first.person_name

    @crumb << { label: MAIN_PAGE_TITLE, url: people_path }
    @crumb << { label: @person_name, url: nil }
    @page_title = @person_name
  end
end
