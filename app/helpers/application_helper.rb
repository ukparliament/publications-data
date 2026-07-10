module ApplicationHelper
  def nice_date_time(field)
    return "" unless field

    time = Time.zone.parse(field)
    time.strftime('%B %d, %Y at %I:%M %p')
  end

  def nice_date(field)
    return "" unless field

    date = Date.parse(field)
    date.strftime('%B %d, %Y')
  end

  def contributor_links_from_array(array_of_contributors)
    array_of_contributors.map do |id, name|
      link_to name, person_path(id)
    end.to_sentence.html_safe
  end
end
