# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :require_user!
end
