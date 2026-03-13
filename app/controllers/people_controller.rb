require 'ostruct'

class PeopleController < ApplicationController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'People'

  PublicationRow = Data.define(:title, :link_to_expression, :created_at, :status, :public, :published_at, :teaser_text)

  def index
    @pagy, @people = pagy(:offset, get_people) # :offset paginator

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    @person = Person.find_by(datagraphs_id: params[:id])

    publications = Datagraphs::Api::GetPublicationDataForAPerson.new.process(params[:id])
    @publications = publications.map { |pub| OpenStruct.new(pub) }

    #
    # The problem with this way is that the whole array is loaded into memory
    #
    # rows = @person.publication_datagraph_ids.map do |dg_id|
    #     publication = PublicationExpression.find_by(datagraphs_id: dg_id)
    #     publication_work = PublicationWork.find_by(datagraphs_id: publication.expression_of)
    #     contributions = Contribution.where(contributed_to: dg_id)

    #     title = publication_work ? publication_work.title : "Work not found for - #{publication_expression_title}"
    #     link_to_expression = publication_path(dg_id)

    #     PublicationRow.new(title: title,
    #                         link_to_expression:  link_to_expression,
    #                         created_at: publication_work.display_created_at,
    #                         status: publication.status,
    #                         public: 'Yes',
    #                         published_at: publication.display_published_at,
    #                         teaser_text: publication.teaser_text

    #                         )
    # end

    @crumb << { label: MAIN_PAGE_TITLE, url: people_path }
    @crumb << { label: @person.name, url: nil }
    @page_title = @person.name
  end

  private

  def get_people
    Person.order(Arel.sql("properties->>'createdAt' DESC"))
  end

  def get_publications_datagraph_ids
    @person.publication_datagraph_ids
  end
end
