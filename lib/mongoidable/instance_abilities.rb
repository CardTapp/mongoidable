# frozen_string_literal: true

module Mongoidable
  # Defines methods necessary to add and remove instance abilities
  module InstanceAbilities
    private

    def mongoidable_identity
      {
          model: model_name&.name || nil,
          id:    attributes.nil? ? nil : id
      }
    end

    def own_abilities
        own_abilities = Mongoidable::Abilities.new(mongoidable_identity, self)
        instance_abilities.each do |ability|
          if ability.base_behavior
            own_abilities.can(ability.action, ability.subject, *ability.extra)
          else
            own_abilities.cannot(ability.action, ability.subject, *ability.extra)
          end
        end
      own_abilities
    end
  end
end