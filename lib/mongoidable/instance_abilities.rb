# frozen_string_literal: true

module Mongoidable
  # Defines methods necessary to add and remove instance abilities
  module InstanceAbilities
    private

    def own_abilities
      @own_abilities = Mongoidable::Abilities.new
      instance_abilities.each do |ability|
        if ability.base_behavior
          @own_abilities.can(ability.action, ability.subject, *ability.extra)
        else
          @own_abilities.cannot(ability.action, ability.subject, *ability.extra)
        end
      end
      @own_abilities
    end
  end
end