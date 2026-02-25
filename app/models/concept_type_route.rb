class ConceptTypeRoute
  attr_reader :concept_type_name

  CONCEPTS_INDEX = 'concepts#index'
  CONCEPTS_SHOW = 'concepts#show'

  def initialize(concept_type_name_from_datagraphs)
    @concept_type_name = concept_type_name_from_datagraphs
  end

  def nice_url_index_path
    "/#{concept_type_name.underscore.tr('_', '-').pluralize}"
  end

  def nice_url_show_path
    "/#{concept_type_name.underscore.tr('_', '-').pluralize}/:id"
  end

  def concept_type_for_defaults
    concept_type_name.underscore.camelize.singularize
  end

  def show_route_name
    concept_type_name.singularize.underscore.to_sym
  end
end

