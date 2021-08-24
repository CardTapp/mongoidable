# frozen_string_literal: true

module Mongoidable
  # Provides a policy finder for PoliciesController
  class PolicyQuery < SimpleDelegator
    extend Memoist

    attr_reader :authorized_user, :params

    def initialize(authorized_user, params)
      @authorized_user = authorized_user
      @params = params
      super(Mongoidable::Policy)
    end

    def object_for_update
      object = find_by(find_params)
      authorized_user.current_ability.subscribe(:after_authorize!) { after_authorize }
      object
    end

    def object_for_index
      where(index_params)
    end

    def object_for_show
      find_by(find_params)
    end

    def object_for_create
      new(create_params)
    end

    def object_for_destroy
      find_by(find_params)
    end

    private

    def unsafe_params
      params.to_unsafe_hash
    end

    def after_authorize
      abilities = Array.wrap(unsafe_params[:instance_ability] || unsafe_params[:instance_abilities])
      Mongoidable::AbilitiesUpdater.new(object_for_update, abilities, replace: unsafe_params[:replace]).call
    end

    def query_type
      Mongoidable::Policy
    end

    def index_params
      { owner_type: params[:owner_type] }
    end

    def create_params
      params.permit
    end

    def find_params
      { id: params[:id] }
    end

    def find_id
      { id: params.to_unsafe_hash[:id] }
    end

    memoize :object_for_index,
            :object_for_update,
            :object_for_show,
            :object_for_destroy,
            :unsafe_params,
            :find_params
  end
end