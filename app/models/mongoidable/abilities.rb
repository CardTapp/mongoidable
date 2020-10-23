# frozen_string_literal: true

# The class that holds all abilities on classes, instances and adhoc
module Mongoidable
  class Abilities
    include ::CanCan::Ability
    include Mongoidable::CaslList

    attr_reader :ability_source, :parent_model
    attr_accessor :rule_type

    def initialize(ability_source, parent_model)
      @parent_model = parent_model
      @ability_source = ability_source
      @rule_type = :adhoc
    end

    def cannot?(*args)
      if can_cache?
        Rails.cache.fetch(ability_cache_key(args), cache_options) { super }
      else
        super
      end
    end

    def cannot(action = nil, subject = nil, *attributes_and_conditions, &block)
      extra = set_rule_extras(attributes_and_conditions)
      super(action, subject, *extra, &block)
    end

    def can?(*args)
      if can_cache?
        Rails.cache.fetch(ability_cache_key(args), cache_options) { super }
      else
        super
      end
    end

    def can(action = nil, subject = nil, *attributes_and_conditions, &block)
      extra = set_rule_extras(attributes_and_conditions)
      super(action, subject, *extra, &block)
    end

    def set_rule_extras(extra)
      extra = [{}] if extra.empty?
      extra.first[:rule_source] = ability_source unless extra.first.key?(:rule_source)
      extra.first[:rule_type] = rule_type
      extra
    end

    private

    def can_cache?
      parent_model.present? && config.enable_caching
    end

    def config
      Mongoidable.configuration
    end

    def ability_cache_key(args)
      "#{config.cache_key_prefix}/#{parent_model.cache_key}/#{args}"
    end

    def ability_cache_expiration
      config.cache_ttl.seconds
    end

    def cache_options
      {
          expires_in:         ability_cache_expiration,
          race_condition_ttl: 10.seconds
      }
    end
  end
end
