require 'ostruct'

class PeopleController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'People'

  def index
    get_letters
    @letter = params[:letter] || "A"
    @total_count = Datagraphs::Api::GetPeople.new.get_total(letter: @letter)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    people = Datagraphs::Api::GetPeople.new.process(
      skip: @pagy.offset,
      limit: @pagy.limit,
      letter: @letter
    )

    @people = people.map { |p| OpenStruct.new(p) }

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    @total_count = Datagraphs::Api::GetPublicationDataForAPerson.new.get_total(person_id: params[:id])

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    publications = Datagraphs::Api::GetPublicationDataForAPerson.new.process(
      person_id: params[:id],
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @publications = publications.map { |pub| OpenStruct.new(pub) }
    @person_name = @publications.any? ? @publications.first.person_name : "No publications"

    @crumb << { label: MAIN_PAGE_TITLE, url: people_path }
    @crumb << { label: @person_name, url: nil }
    @page_title = @person_name
  end

  private

  def get_letters
    @letters = Datagraphs::Api::GetPeople.new.get_letters.first["letters"].sort
  end
end
