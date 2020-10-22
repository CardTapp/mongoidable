# frozen_string_literal: true

module Mongoidable
  # Simple module to return the instances abilities.
  # Ability precedence order
  #   parental static class abilities (including base class abilities)
  #   parental instance abilities
  #   own static class abilities (including base class abilities)
  #   own instance abilities
  module CurrentAbility
    attr_accessor :parent_model

    def current_ability(parent = nil)
      if defined?(Mongoidable::RSpec) && !Mongoidable::RSpec.configuration.with_abilities
        Mongoidable::RSpec::AbilitiesTestStub.new(mongoidable_identity)
      else
        abilities = Mongoidable::Abilities.new(mongoidable_identity, parent || self)
        add_inherited_abilities(abilities)
        add_ancestral_abilities(abilities, parent)
        abilities.merge(own_abilities)
      end
    end

    private

    def add_inherited_abilities(abilities)
      self.class.inherits_from.reduce(abilities) do |sum, inherited_from|
        relation = send(inherited_from[:name])
        next sum if relation.blank?

        order_by = inherited_from[:order_by]
        descending = inherited_from[:direction] == :desc
        next sum if relation.blank?

        relations = Array.wrap(relation)
        relations.sort_by! { |item| item.send(order_by) } if order_by
        relations.reverse! if descending
        relations.each { |object| sum.merge(object.current_ability(self)) }
        sum
      end
    end

    def add_ancestral_abilities(abilities, parent)
      abilities.rule_type = :static
      self.class.ancestral_abilities.each do |ancestral_ability|
        @parent_model = parent
        ancestral_ability.call(abilities, self)
      end
    ensure
      abilities.rule_type = :adhoc
    end
  end
end
