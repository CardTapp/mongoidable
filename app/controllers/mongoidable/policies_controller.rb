# frozen_string_literal: true

# Provides a CRUD api for ability policies.
module Mongoidable
class PoliciesController < ApplicationController
  before_action :policy
  authorize_resource class: "Abilities::Policy"

  def index
    render json: policy, namespace: ControllerSerializers::PoliciesController
  end

  def show
    render json: policy, namespace: ControllerSerializers::PoliciesController
  end

  def create
    policy.save!

    render json: policy, namespace: ControllerSerializers::PoliciesController
  end

  def update
    policy.save!

    render json: policy, namespace: ControllerSerializers::PoliciesController
  end

  def destroy
    policy.destroy!

    head :no_content
  end

  private

  def query
    @query ||= Abilities::PolicyQuery.new(current_user, params)
  end

  def policy
    @policy ||= query.public_send("object_for_#{params[:action]}")
  end
end
end