# frozen_string_literal: true

Mongoidable::Engine.routes.draw do
  resources :abilities, only: %i[index create]
end