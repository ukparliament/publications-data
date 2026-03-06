# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include LibraryDesign::Crumbs

  http_basic_authenticate_with name: "green", password: "goddess"

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::UnknownFormat, with: :unsupported_media_type

  def render_404
    render template: 'errors/not_found', status: :not_found
  end

  private

  def unsupported_media_type
    render plain: 'Not supported', status: :unsupported_media_type
  end
end
