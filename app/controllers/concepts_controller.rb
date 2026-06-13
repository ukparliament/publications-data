require 'ostruct'

class ConceptsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Concepts'

  # OK - we are reworking this to provide a tree structure - every time we drill down, we can provide a list to the publications for that
  # concept and also links to children and parents

  def index
    broader_term = params[:broader_term] || 'Concept'
    concepts = Datagraphs::Api::GetConcepts.new.get_concepts_based_on_broader_term(broader_term: broader_term, skip: 0, limit: 200)
    @concepts = concepts.map { |concept| OpenStruct.new(concept) }
    @sub_title = broader_term == 'Concept' ? 'Top level concepts' : broader_term

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  # def show

  #   #@total_count = Datagraphs::Api::GetConcept.new.get_total(concept_id: params[:id])

  #   @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

  #   collection_and_publication_works = Datagraphs::Api::GetConcept.new.process(
  #     concept_id: params[:id],
  #     skip: @pagy.offset,
  #     limit: @pagy.limit
  #   )

  #   @publication_works = collection_and_publication_works.map { |publication_works| OpenStruct.new(publication_works) }

  #   @concept_name = @publication_works.first.concept_name
  #   @page_title =  @concept_name

  #   @crumb << { label: MAIN_PAGE_TITLE, url: concepts_path }
  #   @crumb << { label: @page_title, url: nil }
  # end

  private

  def get_letters
    @letters = Datagraphs::Api::GetConcepts.new.get_letters.first["letters"].sort
  end

  def process_concepts(letter:, limit:, offset:)

  end

  def process_collection
    collection_and_publication_works = Datagraphs::Api::GetCollection.new.process(params[:id])
    collection_and_publication_works.map { |publication_works| OpenStruct.new(publication_works) }
  end
end




 #{"results":[{"s":{"id":"urn:publications-data:Section:16849","type":"Section","name":"Business and Transport Section","shortName":"BTS","strapLine":"The Business and Transport Section covers topics including transport, pensions, taxation, financial systems and institutions, corporate matters, and employment.","isDefunct":false,"formsPartOf":"urn:publications-data:ResearchService:1"}},{"s":{"id":"urn:publications-data:Section:17113","type":"Section","name":"Economic Policy and Statistics Section","shortName":"EPAS","strapLine":"The Economic Policy and Statistics Section covers policy on topics including the economy, trade and public spending, as well as statistics on a wider range of policy areas, including businesses, employment and poverty.","isDefunct":false,"formsPartOf":"urn:publications-data:ResearchService:1"}},{"s":{"id":"urn:publications-data:Section:25036","type":"Section","name":"Home Affairs Section","shortName":"HAS","strapLine":"The Home Affairs Section covers topics including policing and criminal justice, immigration, civil law, national security, media, equality and human rights.","isDefunct":false,"formsPartOf":"urn:publications-data:ResearchService:1"}},{"s":{"id":"urn:publications-data:Section:298694",       ORDER BY section.name
