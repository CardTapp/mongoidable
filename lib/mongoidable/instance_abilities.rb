# frozen_string_literal: true

module Mongoidable
  # Defines methods necessary to add and remove instance abilities
  module InstanceAbilities
    extend Memoist

    private

    def mongoidable_identity
      {
          model: model_name&.name || nil,
          id:    attributes.nil? ? nil : id
      }
    end

    def own_abilities
      process_instance_abilities(instance_abilities)
    end

    def process_instance_abilities(abilities)
      new_abilities = Mongoidable::Abilities.new(mongoidable_identity, self)
      abilities.each do |ability|
        if ability.base_behavior
          new_abilities.can(ability.action, ability.subject, *ability.extra)
        else
          new_abilities.cannot(ability.action, ability.subject, *ability.extra)
        end
      end
      new_abilities
    end
    memoize :own_abilities
  end
end