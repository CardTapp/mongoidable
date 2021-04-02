# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, class_name: "User"
end
