# frozen_string_literal: true

module Mongoidable
  # Query Object for update and index actions
  # in the ability controller
  class AbilityQuery < SimpleDelegator
    extend Memoist

    attr_reader :authorized_user, :authorized_ability, :params

    def initialize(authorized_user, params)
      @authorized_user    = authorized_user
      @authorized_ability = authorized_user.current_ability
      @params             = params
      super(query_type)
    end

    def object_for_index
      find_by(find_params)
    end

    def object_for_create
      object_for_update
    end

    def object_for_update
      object = find_by(find_params)
      authorized_user.current_ability.subscribe(:after_authorize!) { after_authorize }
      object
    end

    def save!
      updater.save!
      object_for_update.save!
    end

    private

    def after_authorize
      updater.call(false)
    end

    def updater
      if has_policy?
        Mongoidable::PoliciesUpdater.new(object_for_update,
                                         unsafe_params[:policy_id],
                                         unsafe_params[:policy_relation],
                                         requirements: unsafe_params[:requirements],
                                         remove: unsafe_params[:remove_policy])
      else
        abilities = Array.wrap(unsafe_params[:instance_ability] || unsafe_params[:instance_abilities])
        Mongoidable::AbilitiesUpdater.new(object_for_update, abilities, replace: unsafe_params[:replace])
      end
    end

    def unsafe_params
      params.to_unsafe_hash
    end

    def has_policy?
      params.key?(:policy_id)
    end

    def query_type
      params[:owner_type].camelize.constantize
    rescue StandardError
      raise ArgumentError, "Invalid query type"
    end

    def find_params
      { id: params[:owner_id] }
    end

    memoize :object_for_index,
            :object_for_create,
            :object_for_update,
            :find_params,
            :updater
  end
end
