# frozen_string_literal: true

module Mongoidable
  class PolicyRelation
    include Mongoid::Document
    include Mongoidable::Document

    field :requirements, type: Hash
    belongs_to :policy, class_name: Mongoidable.configuration.policy_class

    def add_inherited_abilities
      @abilities.merge(merge_requirements)
    end

    def merge_requirements
      result = Mongoidable::Abilities.new(mongoidable_identity, self)

      policy_instance_abilities = policy.instance_abilities.clone
      policy_instance_abilities.each do |ability|
        ability.merge_requirements(requirements)
        if ability.base_behavior
          result.can(ability.action, ability.subject, *ability.extra)
        else
          result.cannot(ability.action, ability.subject, *ability.extra)
        end
      end
      result
    end
  end
end
