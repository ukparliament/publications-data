require 'ostruct'

class PublicationsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Published publications'

  def index
    @total_count = Datagraphs::Api::GetPublications.new.get_total

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    publications = Datagraphs::Api::GetPublications.new.process(
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @publications = publications.map { |pub| OpenStruct.new(pub) }

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    @publication_work_id = params[:id]

    publication = Datagraphs::Api::GetPublication.new.get_published_publication_details(publication_work_id: @publication_work_id).first
    @publication = OpenStruct.new(publication)

    @concepts = @publication.concepts ? @publication.concepts.zip(@publication.concept_ids) : []

    title = @publication.title

    contributions = Datagraphs::Api::GetPublication.new.get_contributors(publication_work_id: @publication_work_id).uniq
    @contributions = contributions.map { |contribution| OpenStruct.new(contribution) }

    resources = Datagraphs::Api::GetPublication.new.get_resources(publication_work_id: @publication_work_id)
    @resources = resources.map { |resource| OpenStruct.new(resource) if resource["file_title"].present? }

    @crumb << { label: MAIN_PAGE_TITLE, url: publications_path }
    @crumb << { label: title, url: nil }
    @page_title =  title
  end
end
