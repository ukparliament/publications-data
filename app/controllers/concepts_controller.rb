class ConceptsController < ApplicationController
  before_action :set_concept_type

  def index
    @concepts = Concept.where(datagraphs_type: @concept_type)
  end

  def show
    @id = params[:id]
    @datagraphs_id = "urn:#{$PROJECT_ID}:#{@concept_type}:#{@id}"

    @concept = Concept.find_by(datagraphs_id: @datagraphs_id)

    property = params["property"]

    if property
      # Load extras
      @concepts = Concept.where(datagraphs_id: @concept.properties[property])
    else
      ap "No property"
    end
  end

  private

  def set_concept_type
    @concept_type = params[:concept_type]
  end
end

