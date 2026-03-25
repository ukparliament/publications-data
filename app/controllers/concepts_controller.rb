class ConceptsController < AuthenticatedController
  before_action :set_concept_type

  def index
    @concepts = Concept.where(datagraphs_type: @concept_type)
  end

  def show
    @id = params[:id]
    @datagraphs_id = "urn:#{$PROJECT_ID}:#{@concept_type}:#{@id}"

    @concept = Concept.find_by(datagraphs_id: @datagraphs_id)

    property = params["property"]
    @title = params["title"]

    if property
      @title = @title % { main_concept: @concept.display_title }
      # Load extras - these are the thingds we want to display, filtered by the concept
      # i.e. the main concept is House, but the filtered concepts are the Research Services for the house
      @filtered_concepts = Concept.where(datagraphs_id: @concept.properties[property])
    else
      @filtered_concepts = []
      ap "No property"
    end
  end

  private

  def set_concept_type
    @concept_type = params[:concept_type]
  end
end

