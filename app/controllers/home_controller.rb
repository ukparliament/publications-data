class HomeController < ApplicationController
  def index; end

  def cookies; end

  def examples
    @page_title = "Examples"
    @crumb << { label: 'Examples', url: nil }
  end
end
