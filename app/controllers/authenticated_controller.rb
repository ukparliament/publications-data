# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :require_user!

  def require_user!
    return if current_user || $DISABLE_AUTHENTICATION

    redirect_to root_path, alert: "Access denied, please log in."
  end
end
