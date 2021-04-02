# frozen_string_literal: true

#TODO: Ensure Mongoid railtie rescue_responses handles DocumentNotFound, Validations
#TODO: For cancan add the dispatch rescue
# config.action_dispatch.rescue_responses.merge!(
#   'ActiveRecord::RecordNotFound'   => :not_found,
#   'ActiveRecord::StaleObjectError' => :conflict,
#   'ActiveRecord::RecordInvalid'    => :unprocessable_entity,
#   'ActiveRecord::RecordNotSaved'   => :unprocessable_entity
# )
module Mongoidable
class AbilitiesController < ApplicationController
  load_resource :current_ability, class: Mongoidable::Ability.name, parent: true, through: :request_object, singleton: true
  authorize_resource :request_object, parent_action: :index_abilities, only: :index
  authorize_resource :request_object, parent_action: :update_abilities, only: :create

  def index
    render json: { "instance-abilities": request_object.instance_abilities }
  end

  def create
    request_object.save!
    render json: { "instance-abilities": [query.object_for_create.instance_abilities] }
  end

  private

  attr_reader :user

  def query
    @query ||= Mongoidable::AbilityQuery.new(current_user, params)
  end

  def request_object
    @request_object ||= query.public_send("object_for_#{params[:action]}")
  end
end
end