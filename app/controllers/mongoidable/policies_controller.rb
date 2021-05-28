# frozen_string_literal: true

# Provides a CRUD api for ability policies.
module Mongoidable
  class PoliciesController < ApplicationController
    respond_to :json
    before_action :policy
    authorize_resource class: "Mongoidable::Policy"

    def index
      render json: policy, root: :policies, namespace: ::Mongoidable
    end

    def show
      render json: policy, root: :policies, namespace: ::Mongoidable
    end

    def create
      policy.save!

      render json: policy, root: :policies, namespace: ::Mongoidable
    end

    def update
      policy.save!

      render json: policy, root: :policies, namespace: ::Mongoidable
    end

    def destroy
      policy.destroy!

      head :no_content
    end

    private

    def query
      @query ||= Mongoidable.configuration.policy_query.constantize.new(current_user, params)
    end

    def policy
      @policy ||= query.public_send("object_for_#{params[:action]}")
    end
  end
end