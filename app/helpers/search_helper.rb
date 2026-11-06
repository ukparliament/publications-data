module SearchHelper
  def show_search?
    current_user || $DISABLE_AUTHENTICATION
  end
end
