# frozen_string_literal: true

# The class that holds all abilities on classes, instances and adhoc
module Mongoidable
  class Abilities
    include ::CanCan::Ability
    include Mongoidable::CaslList

    attr_reader :ability_source
    attr_accessor :rule_type

    def initialize(ability_source)
      @ability_source = ability_source
      @rule_type = :adhoc
    end

    def cannot(action = nil, subject = nil, *attributes_and_conditions, &block)
      extra = set_rule_extras(attributes_and_conditions)
      super(action, subject, *extra, &block)
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
  end
end
