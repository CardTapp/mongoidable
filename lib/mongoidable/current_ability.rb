# frozen_string_literal: true

module Mongoidable
  # Simple module to return the instances abilities.
  # Ability precedence order
  #   parental static class abilities (including base class abilities)
  #   parental instance abilities
  #   own static class abilities (including base class abilities)
  #   own instance abilities
  module CurrentAbility
    attr_reader :parent_model

    def current_ability(parent = nil, skip_cache: false)
      with_ability_cache(skip_cache) do
        abilities = Mongoidable::Abilities.new(mongoidable_identity)
        add_inherited_abilities(abilities, skip_cache)
        add_ancestral_abilities(abilities, parent)
        abilities.merge(own_abilities)
      end
    end

    private

    def should_cache?
      config.enable_caching && !new_record?
    end

    def with_ability_cache(skip_cache, &block)
      if should_cache? && !skip_cache
        Rails.cache.fetch(ability_cache_key, expires_in: ability_cache_expiration, &block)
      else
        yield
      end
    end

    def add_inherited_abilities(abilities, skip_cache)
      self.class.inherits_from.reduce(abilities) do |sum, inherited_from|
        relation = send(inherited_from[:name])
        next sum unless relation.present?

        order_by = inherited_from[:order_by]
        descending = inherited_from[:direction] == :desc

        relations = Array.wrap(relation)
        relations.sort_by! { |item| item.send(order_by) } if order_by
        relations.reverse! if descending
        relations.each { |object| sum.merge(object.current_ability(self, skip_cache: skip_cache)) }
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

    def config
      Mongoidable.configuration
    end

    def ability_cache_key
      "#{config.cache_key_prefix}/#{cache_key}"
    end

    def ability_cache_expiration
      config.cache_ttl.seconds
    end
  end
end
