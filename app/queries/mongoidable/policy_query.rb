# frozen_string_literal: true

module Mongoidable
module Abilities
  # Provides a policy finder for PoliciesController
  class PolicyQuery < SimpleDelegator
    include Abilities::Concerns::UpdatesAbilities
    extend Memoist

    attr_reader :authorized_user, :params

    def initialize(authorized_user, params)
      @authorized_user = authorized_user
      @params = params
      super(Abilities::Policy)
    end

    def object_for_index
      filter_by_params(index_params)
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

    def query_type
      Abilities::Policy
    end

    def index_params
      params.permit(:type)
    end

    def create_params
      params.permit
    end

    def find_params
      params.permit(:type, :id)
    end

    memoize :object_for_index,
            :object_for_update,
            :find_params
  end
end
end