module PublicationHelper
  def title_of_publication_work_but_link_to_expression(publication_expression_datagraphs_id:, publication_work_datagraphs_id:, publication_expression_title: "Not found")
    publication_work = Concept.find_by(datagraphs_id: publication_work_datagraphs_id)

    label = if publication_work
              publication_work.title
            else
              "Work not found for - #{publication_expression_title}"
            end

    link_to label, publication_path(publication_expression_datagraphs_id)
  end

  def contribution_is_public

  end

  def person_details_and_role(person_details, role)
    name = person_details[1]
    id = person_details[0]

    label = role.present? ? "#{name} - (#{role})" : name
    link_to label, person_path(id)
  end
end
