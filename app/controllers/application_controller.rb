# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include LibraryDesign::Crumbs

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::UnknownFormat, with: :unsupported_media_type

  helper_method :current_user

  def render_404
    render template: 'errors/not_found', status: :not_found
  end

  private

  def current_user
    return session[:user_id] if session[:user_id].present?
  end

  def require_user!
    return if current_user
    redirect_to root_path, alert: "Access denied"
  end

  def unsupported_media_type
    render plain: 'Not supported', status: :unsupported_media_type
  end
end
