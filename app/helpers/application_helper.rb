module ApplicationHelper

  def concept_type_conversion(concept_type)
    if concept_type.in?(Constants::CONCEPT_TITLE_MAP.keys)
      Constants::CONCEPT_TITLE_MAP[concept_type]
    else
      concept_type.underscore.humanize.pluralize
    end
  end

  def nice_date_time(field)
    return "" unless field

    time = Time.zone.parse(field)
    time.strftime('%B %d, %Y at %I:%M %p')
  end

  def new_reference_to_link(reference)
    ref_array = reference.split(':')

    type_thing = ref_array[-2]

    type_thing = concept_type_conversion(type_thing)

    thing_id = ref_array[-1]

    concept = Concept.find_by(datagraphs_id: reference)

    if concept
      label = concept.label || concept.title

      if label
        link_to label, send("#{type_thing.parameterize.underscore.downcase.singularize}_path", id: reference)
      else
        name = concept.properties["name"]
        link_to name, send("#{type_thing.parameterize.underscore.downcase.singularize}_path", id: reference)
      end
    else
      reference
    end

  end

  # Example reference
  # "urn:subject-specialist-finder:Section:67716"
  def convert_reference_to_link(reference)
    ref_array = reference.split(':')

    type_thing = ref_array[-2]

    type_thing = concept_type_conversion(type_thing)

    thing_id = ref_array[-1]

    concept = Concept.find_by(datagraphs_id: reference)

    if concept
      label = concept.label || concept.title

      if label
        link_to label, send("#{type_thing.parameterize.underscore.downcase.singularize}_path", id: thing_id)
      else
        name = concept.properties["name"]
        link_to name, send("#{type_thing.parameterize.underscore.downcase.singularize}_path", id: thing_id)
      end
    else
      reference
    end
  end
end
