# frozen_string_literal: true

module Mongoidable
  class PolicyLocator
    attr_reader :policy_id

    def initialize(_model, policy_id, _policy_relation, _requirements)
      @policy_id = policy_id
    end

    def call
      Mongoidable::Policy.find(policy_id)
    end
  end
end
