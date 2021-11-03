# frozen_string_literal: true

# The class that holds all abilities on classes, instances and adhoc
module Mongoidable
  class Abilities
    extend Memoist
    include ::CanCan::Ability
    include Mongoidable::CaslList

    attr_reader :ability_source, :parent_model
    attr_accessor :rule_type

    def initialize(ability_source, parent_model, event_subscriptions = nil)
      @parent_model = parent_model
      @ability_source = ability_source
      @rule_type = :adhoc
      @events = event_subscriptions
      @rules_index ||= {}
    end

    def cannot(action = nil, subject = nil, *attributes_and_conditions, &block)
      extra = set_rule_extras(attributes_and_conditions)
      super(action, subject, *extra, &block)
    end

    def can(action = nil, subject = nil, *attributes_and_conditions, &block)
      extra = set_rule_extras(attributes_and_conditions)
      super(action, subject, *extra, &block)
    end

    def empty_clone
      Mongoidable::Abilities.new(ability_source, parent_model, events)
    end


    private

    def set_rule_extras(extra)
      extra_first_hash = extra.presence&.select { |arg| arg.respond_to?(:key?) }&.first
      first_hash = extra_first_hash || {}

      first_hash[:rule_source] = ability_source unless first_hash.key?(:rule_source)
      first_hash[:rule_type] = rule_type

      extra = [first_hash] + (extra.presence || []) if !extra_first_hash

      extra
    end

    def config
      Mongoidable.configuration
    end
  end
end
