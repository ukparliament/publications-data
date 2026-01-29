module ApplicationHelper
  def concept_label(concept)
    concept.label || concept.properties["name"]
  end

  def process_property_value(key, property_value)
    return "" unless property_value.present?

    if property_value.is_a?(Array)

      property_value.map do |value|
        process_individual_thing(value)
      end.join(', ')
    elsif key == "publishedAt"
      time = Time.zone.parse(property_value)
      time.strftime('%B %d, %Y at %I:%M %p')
    else
      process_individual_thing(property_value)
    end
  end

  def process_key(key)
    key.underscore.humanize.capitalize
  end

  def process_individual_thing(value)
    return value.to_s if value.is_a?(TrueClass) || value.is_a?(FalseClass)

    if value.to_s.include?($PROJECT_ID)
      convert_reference_to_link(value)
    else
      value.to_s
    end
  end

  # Example reference
  # "urn:subject-specialist-finder:Section:67716"
  def convert_reference_to_link(reference)
    ref_array = reference.split(':')

    type_thing = ref_array[-2]
    thing_id = ref_array[-1]

    concept = Concept.find_by(datagraphs_id: reference)

    if concept
      label = concept.label || concept.title

      if label
        link_to label, send("#{type_thing.underscore.downcase.singularize}_path", id: thing_id)
      else
        name = concept.properties["name"]
        link_to name, send("#{type_thing.underscore.downcase.singularize}_path", id: thing_id)
      end
    else
      reference
    end
  end
end
