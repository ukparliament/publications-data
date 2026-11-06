module SearchHelper
  def show_search?
    current_user || $DISABLE_AUTHENTICATION
  end

  SEARCH_LOOKUP = {
    "PublicationWork" => "Briefing"
  }.freeze

  def convert_type_for_search(type)
    SEARCH_LOOKUP[type]
  end
end
