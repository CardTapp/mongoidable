# frozen_string_literal: true

Rails.application.routes.draw do
  mount Mongoidable::Engine => "/mongoidable"
end
