module ApplicationHelper
  def nice_date_time(field)
    return "" unless field

    time = Time.zone.parse(field)
    time.strftime('%B %d, %Y at %I:%M %p')
  end
end
