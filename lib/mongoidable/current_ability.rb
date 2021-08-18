# frozen_string_literal: true

module Mongoidable
  # Simple module to return the instances abilities.
  # Ability precedence order
  #   parental static class abilities (including base class abilities)
  #   parental instance abilities
  #   own static class abilities (including base class abilities)
  #   own instance abilities
  module CurrentAbility
    extend Memoist
    attr_accessor :parent_model

    def current_ability(parent = @parent_model || nil)
      @parent_model ||= parent
      if !@abilities.present? || @renew_abilities
        @abilities = @abilities&.empty_clone || Mongoidable::Abilities.new(mongoidable_identity, @parent_model || self)
        @abilities.merge(inherited_abilities(@renew_abilities))
        @abilities.merge(ancestral_abilities)
        @abilities.merge(own_abilities(@renew_instance_abilities))
        @renew_abilities = false
      end
      @abilities
    end

    def renew_abilities(_relation = nil)
      parent_model.renew_abilities if parent_model
      @renew_abilities = true
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
      @abilities.merge(inherited_abilities)
    end

    def inherited_abilities
      inherited = Mongoidable::Abilities.new(mongoidable_identity, parent_model || self)
      self.class.inherits_from.each do |inherited_from|
        rel(inherited_from).map { |object| inherited.merge(object.current_ability(self)) }
      end.flatten
      inherited
    end

    def add_ancestral_abilities
      @abilities.merge(ancestral_abilities)
    end

    def ancestral_abilities
      ancestral = Mongoidable::Abilities.new(mongoidable_identity, parent_model || self)
      ancestral.rule_type = :static
      self.class.ancestral_abilities.each do |ancestral_ability|
        ancestral_ability.call(ancestral, self)
      end

      ancestral
    end

    memoize :ancestral_abilities, :inherited_abilities
  end
end
