module PublicationHelper
  def person_details_and_role(person_details, role)
    name = person_details[1]
    id = person_details[0]

    label = role.present? ? "#{name} - (#{role})" : name
    link_to label, person_path(id)
  end
end
