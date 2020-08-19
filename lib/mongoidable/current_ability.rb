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
      abilities = Mongoidable::Abilities.new(mongoidable_identity)
      add_inherited_abilities(abilities)
      add_ancestral_abilities(abilities)
      abilities.merge(own_abilities)
    end

    private

    def add_inherited_abilities(abilities)
      self.class.inherits_from.reduce(abilities) do |sum, inherited_from|
        relation = send(inherited_from[:name])
        order_by = inherited_from[:order_by]
        descending = inherited_from[:direction] == :desc
        next sum unless relation.present?

        relations = Array.wrap(relation)
        relations.sort_by! { |item| item.send(order_by) } if order_by
        relations.reverse! if descending
        relations.each { |object| sum.merge(object.current_ability) }
        sum
      end
    end

    def add_ancestral_abilities(abilities)
      self.class.ancestral_abilities.each do |ancestral_ability|
        abilities.class_abilities do
          ancestral_ability.call(abilities, self)
        end
      end
    end
  end
end
