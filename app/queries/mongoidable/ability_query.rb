# frozen_string_literal: true

module Mongoidable
  # Query Object for update and index actions
  # in the ability controller
  class AbilityQuery < SimpleDelegator
    include Mongoidable::Concerns::UpdatesAbilities
    extend Memoist

    attr_reader :authorized_user, :params

    def initialize(authorized_user, params)
      @authorized_user = authorized_user
      @params = params
      super(query_type)
    end

    def object_for_index
      find_by(find_params)
    end

    def object_for_create
      object_for_update
    end

    private

    def query_type
      params[:type].camelize.constantize
    rescue
      raise ArgumentError, "Invalid query type"
    end

    def find_params
      {id: params[:owner_id]}
    end

    memoize :object_for_index,
            :object_for_create,
            :find_params
  end
end
