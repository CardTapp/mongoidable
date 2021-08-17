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

    def current_ability(parent = @parent_model || nil)
      @parent_model ||= parent
      if !@abilities.present? || changed_with_relations? || @renew_abilities
        @abilities = @abilities&.empty_clone || Mongoidable::Abilities.new(mongoidable_identity, @parent_model || self)
        add_inherited_abilities
        add_ancestral_abilities(@parent_model)
        @abilities.merge(own_abilities)
        @renew_abilities = false
      end
      @abilities
    end

    def renew_abilities(relation = nil)
      relation.renew_abilities if relation && relation.respond_to?(:renew_abilities)
      parent_model.renew_abilities if parent_model
      @renew_abilities = true
      @own_abilities = nil
      @ancestral_abilities = nil

    end

    private

    def rel(inherited_from)
      relation = send(inherited_from[:name])
      return [] if relation.blank?

      order_by = inherited_from[:order_by]
      descending = inherited_from[:direction] == :desc

      relations = Array.wrap(relation)
      relations.sort_by! { |item| item.send(order_by) } if order_by
      relations.reverse! if descending
      relations
    end

    def add_inherited_abilities
      self.class.inherits_from.reduce(@abilities) do |sum, inherited_from|
        rel(inherited_from).each { |object| sum.merge(object.current_ability(self)) }
        sum
      end
    end

    def add_ancestral_abilities(parent)
      ancestral_abilities = Mongoidable::Abilities.new(mongoidable_identity, parent || self)
      ancestral_abilities.rule_type = :static
      self.class.ancestral_abilities.each do |ancestral_ability|
        ancestral_ability.call(ancestral_abilities, self)
      end

      @abilities.merge(ancestral_abilities)
    end
  end
end
