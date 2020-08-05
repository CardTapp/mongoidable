# frozen_string_literal: true

module Mongoidable
  # Simple module to return the instances abilities.
  # Ability precedence order
  #   parental static class abilities (including base class abilities)
  #   parental instance abilities
  #   own static class abilities (including base class abilities)
  #   own instance abilities
  module CurrentAbility
    def current_ability
      abilities = Mongoidable::Abilities.new
      add_inherited_abilities(abilities)
      add_ancestral_abilities(abilities)
      abilities.merge(own_abilities)
    end

    private

    def add_inherited_abilities(abilities)
      self.class.inherits_from.reduce(abilities) do |sum, inherited_from|
        relation = send(inherited_from.name)
        sum.merge(relation.current_ability) if relation.present?
      end
    end

    def add_ancestral_abilities(abilities)
      self.class.ancestral_abilities.each do |ancestral_ability|
        ancestral_ability.call(abilities)
      end
    end
  end
end
