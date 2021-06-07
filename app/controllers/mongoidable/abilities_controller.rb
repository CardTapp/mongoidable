# frozen_string_literal: true

# TODO: Ensure Mongoid railtie rescue_responses handles DocumentNotFound, Validations
# TODO: For cancan add the dispatch rescue
# config.action_dispatch.rescue_responses.merge!(
#   'ActiveRecord::RecordNotFound'   => :not_found,
#   'ActiveRecord::StaleObjectError' => :conflict,
#   'ActiveRecord::RecordInvalid'    => :unprocessable_entity,
#   'ActiveRecord::RecordNotSaved'   => :unprocessable_entity
# )
module Mongoidable
  class AbilitiesController < ApplicationController
    respond_to :json
    before_action :request_object
    authorize_resource :request_object, parent_action: :read_abilities, only: :index
    authorize_resource :request_object, parent_action: :manage_abilities, only: :create

    def index
      render json: request_object.instance_abilities, namespace: Mongoidable, root: :"instance-abilities"
    end

    def create
      query.save!
      render json: request_object.instance_abilities, namespace: Mongoidable, root: :"instance-abilities"
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