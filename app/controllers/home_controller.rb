class HomeController < ApplicationController

  def index
    unless current_user.present?
      redirect_to users_sign_in_path
    end
  end
end