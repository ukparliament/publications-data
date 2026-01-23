class ConceptsController < ApplicationController
  def index
    @concept_type = params[:concept_type]

    @concepts = Concept.where(datagraphs_type: @concept_type)
  end

  def show
    @concept_type = params[:concept_type]
    @id = params[:id]
    @datagraphs_id = "urn:#{$PROJECT_ID}:#{@concept_type}:#{@id}"

    @concept = Concept.find_by(datagraphs_id:  @datagraphs_id)
  end
end

