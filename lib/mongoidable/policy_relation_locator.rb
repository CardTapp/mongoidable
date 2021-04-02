# frozen_string_literal: true

module Mongoidable
  class PolicyRelationLocator
    attr_reader :policy_id, :policy_relation, :model, :requirements

    def initialize(model, policy_id, policy_relation, requirements)
      @model = model
      @policy_id = BSON::ObjectId(policy_id)
      @requirements = requirements
      @policy_relation = policy_relation
    end

    def call
      model.send(policy_relation).find_or_initialize_by(policy_id: policy_id, requirements: requirements)
    end
  end
end
