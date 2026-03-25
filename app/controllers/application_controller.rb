# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include LibraryDesign::Crumbs
  include Passwordless::ControllerHelpers

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::UnknownFormat, with: :unsupported_media_type

  helper_method :current_user

  def render_404
    render template: 'errors/not_found', status: :not_found
  end

  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  def require_user!
    return if current_user
    save_passwordless_redirect_location!(User) # <-- optional, see below
    redirect_to root_path, alert: "You are not worthy!"
  end

  def unsupported_media_type
    render plain: 'Not supported', status: :unsupported_media_type
  end
end
