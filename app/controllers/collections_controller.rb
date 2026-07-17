require 'ostruct'

class CollectionsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Collections'

  def index
    @collections = process_collections

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show

    @total_count = Datagraphs::Api::GetCollection.new.get_total(collection_id: params[:id])

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    collection_and_publication_works = Datagraphs::Api::GetCollection.new.process(
      collection_id: params[:id],
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @publication_works = collection_and_publication_works.map { |publication_works| OpenStruct.new(publication_works) }

    @collection_name = @publication_works.first.collection_name
    @page_title =  @collection_name

    @crumb << { label: MAIN_PAGE_TITLE, url: collections_path }
    @crumb << { label: @page_title, url: nil }
  end

  private

  def process_collections
    collections = Datagraphs::Api::GetCollections.new.process

    ap collections
    collections.each { |collection| collection["id"] = collection["collection"]["id"]}
    collections.map { |collection| OpenStruct.new(collection) }
  end

  def process_collection
    collection_and_publication_works = Datagraphs::Api::GetCollection.new.process(params[:id])
    collection_and_publication_works.map { |publication_works| OpenStruct.new(publication_works) }
  end
end
