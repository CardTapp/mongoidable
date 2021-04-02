module Mongoidable
  class PoliciesUpdater
    extend Memoist
    attr_reader :model, :policy_id, :policy_relation, :remove, :requirements

    def initialize(model, policy_id, policy_relation, requirements: {}, remove: false)
      @model = model
      @policy_id = policy_id
      @remove = ActiveModel::Type::Boolean.new.cast(remove)
      @policy_relation = policy_relation
      @requirements = requirements
    end

    def call
      remove_policy? ? remove_policy : add_policy
      model.save
    end

    private

    def model_type
      model.class.name.downcase
    end

    def add_policy
      relation = relation_locator.call
      relation.policy = Mongoidable.configuration.policy_locator.constantize.new(
          model, policy_id, policy_relation, requirements
        ).call.id
    end

    def remove_policy
      relation_locator.call&.destroy
    end

    def remove_policy?
      remove
    end

    def relation_locator
      Mongoidable.configuration.policy_relation_locator.constantize.new(
          model, policy_id, policy_relation, requirements
        )
    end
  end
end