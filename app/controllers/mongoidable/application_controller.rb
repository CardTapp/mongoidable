module Mongoidable
  class ApplicationController < ActionController::API
    def current_ability
      @current_ability ||= current_user.current_ability
    end
  end
end