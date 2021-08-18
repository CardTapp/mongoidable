# frozen_string_literal: true

module Mongoidable
  class PolicyRelation
    extend Memoist
    include Mongoid::Document
    include Mongoidable::Document

    field :requirements, type: Hash
    belongs_to :policy, class_name: Mongoidable.configuration.policy_class, polymorphic: true

    def inherited_abilities
      merged_policy_requirements
    end

    def merged_policy_requirements
      merged_policy_requirements = Mongoidable::Abilities.new(mongoidable_identity, self)
      return merged_policy_requirements unless policy

      policy_instance_abilities = policy.instance_abilities.clone
      policy_instance_abilities.each do |ability|
        ability.merge_requirements(requirements)
        if ability.base_behavior
          merged_policy_requirements.can(ability.action, ability.subject, *ability.extra)
        else
          merged_policy_requirements.cannot(ability.action, ability.subject, *ability.extra)
        end
      end

      merged_policy_requirements
    end

    memoize :inherited_abilities
  end
end
