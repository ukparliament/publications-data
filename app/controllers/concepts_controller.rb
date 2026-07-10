require 'ostruct'

class ConceptsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Concepts'

  def index
    get_letters

    @letter = params[:letter] || "A"
    @total_count = Datagraphs::Api::GetConcepts.new.get_total(letter: @letter)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 99)

    concepts = Datagraphs::Api::GetConcepts.new.process(
      letter: @letter,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @concepts = concepts.map { |c| OpenStruct.new(c) }

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    concept_id = params[:id]
    redirect_to publications_concept_path(concept_id)
  end

  def publications
    concept_id = params[:id]

    concept = Datagraphs::Api::GetConcept.new.process(concept_id: concept_id).first
    @concept = OpenStruct.new(concept)

    # #@total_count = Datagraphs::Api::GetConcept.new.get_total(concept_id: params[:id])

    # @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    # collection_and_publication_works = Datagraphs::Api::GetConcept.new.process(
    #   concept_id: params[:id],
    #   skip: @pagy.offset,
    #   limit: @pagy.limit
    # )

   # @publication_works = collection_and_publication_works.map { |publication_works| OpenStruct.new(publication_works) }

   # @concept_name = @publication_works.first.concept_name
    @page_title =  @concept.label

    @crumb << { label: MAIN_PAGE_TITLE, url: concepts_path }
    @crumb << { label: @page_title, url: nil }
  end

  def broader_terms
    concept_id = params[:id]
    concept = Datagraphs::Api::GetConcept.new.process(concept_id: concept_id).first
    @concept = OpenStruct.new(concept)

    bt = Datagraphs::Api::GetConcept.new.and_broader_terms(concept_id: concept_id)
    @broader_terms = bt.map { |s| OpenStruct.new(s) }

    @page_title = "#{@concept.concept_name} - Broader terms"

    @crumb << { label: MAIN_PAGE_TITLE, url: concepts_path }
    @crumb << { label: @concept.concept_name, url: concept_path(concept_id) }
    @crumb << { label: "Broader terms", url: nil }
  end

  def narrower_subjects
    concept_id = params[:id]
    concept = Datagraphs::Api::GetConcept.new.process(concept_id: concept_id).first
    @concept = OpenStruct.new(concept)

    ns = Datagraphs::Api::GetConcept.new.and_narrower_subjects(concept_id: concept_id)
    @narrower_subjects = ns.map { |s| OpenStruct.new(s) }

    @page_title = "#{@concept.concept_name} - Narrower subjects"

    @crumb << { label: MAIN_PAGE_TITLE, url: concepts_path }
    @crumb << { label: @concept.concept_name, url: concept_path(concept_id) }
    @crumb << { label: "Narrower subjects", url: nil }
  end

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
