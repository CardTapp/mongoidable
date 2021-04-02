# frozen_string_literal: true

module Mongoidable
  class ApplicationController < ActionController::API
    delegate :current_ability, to: :current_user
  end
end