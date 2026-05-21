require 'ostruct'

class ConceptsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Concepts'

  def index
    get_letters
    @letter = params[:letter] || "A"
    @total_count = Datagraphs::Api::GetConcepts.new.get_total(letter: @letter)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)



    @concepts = process_concepts(letter: @letter, limit: @pagy.limit, offset: @pagy.offset)

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show

    #@total_count = Datagraphs::Api::GetConcept.new.get_total(concept_id: params[:id])

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    collection_and_publication_works = Datagraphs::Api::GetConcept.new.process(
      concept_id: params[:id],
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @publication_works = collection_and_publication_works.map { |publication_works| OpenStruct.new(publication_works) }

    @concept_name = @publication_works.first.concept_name
    @page_title =  @concept_name

    @crumb << { label: MAIN_PAGE_TITLE, url: concepts_path }
    @crumb << { label: @page_title, url: nil }
  end

  private

  def get_letters
    @letters = Datagraphs::Api::GetConcepts.new.get_letters.first["letters"].sort
  end

  def process_concepts(letter:, limit:, offset:)
    concepts = Datagraphs::Api::GetConcepts.new.process(letter: letter, skip: offset, limit: limit)
   # collections.each { |collection| collection["id"] = collection["collection"]["id"]}
    concepts.map { |concept| OpenStruct.new(concept) }
  end

  def process_collection
    collection_and_publication_works = Datagraphs::Api::GetCollection.new.process(params[:id])
    collection_and_publication_works.map { |publication_works| OpenStruct.new(publication_works) }
  end
end




 #{"results":[{"s":{"id":"urn:publications-data:Section:16849","type":"Section","name":"Business and Transport Section","shortName":"BTS","strapLine":"The Business and Transport Section covers topics including transport, pensions, taxation, financial systems and institutions, corporate matters, and employment.","isDefunct":false,"formsPartOf":"urn:publications-data:ResearchService:1"}},{"s":{"id":"urn:publications-data:Section:17113","type":"Section","name":"Economic Policy and Statistics Section","shortName":"EPAS","strapLine":"The Economic Policy and Statistics Section covers policy on topics including the economy, trade and public spending, as well as statistics on a wider range of policy areas, including businesses, employment and poverty.","isDefunct":false,"formsPartOf":"urn:publications-data:ResearchService:1"}},{"s":{"id":"urn:publications-data:Section:25036","type":"Section","name":"Home Affairs Section","shortName":"HAS","strapLine":"The Home Affairs Section covers topics including policing and criminal justice, immigration, civil law, national security, media, equality and human rights.","isDefunct":false,"formsPartOf":"urn:publications-data:ResearchService:1"}},{"s":{"id":"urn:publications-data:Section:298694",       ORDER BY section.name
