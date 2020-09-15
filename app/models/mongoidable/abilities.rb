# frozen_string_literal: true

# The class that holds all abilities on classes, instances and adhoc
module Mongoidable
  class Abilities
    include ::CanCan::Ability
    attr_reader :ability_source
    attr_accessor :rule_type

    def initialize(ability_source)
      @ability_source = ability_source
      @rule_type = :adhoc
    end

    def to_casl_list
      rules.map { |rule| Mongoidable::CaslHash.new(rule) }
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
      extra.first[:parent] = self
      extra
    end

    private

    def marshal_dump
      { ability_source: @ability_source, rule_type: @rule_type, rules: @rules, aliased_actions: @aliased_actions }
    end

    def marshal_load(hash)
      @ability_source = hash[:ability_source]
      @rule_type = hash[:rule_type]
      @rules = hash[:rules]
      @aliased_actions = hash[:aliased_actions]

      rules = @rules.clone
      @rules = []
      rules&.each do |rule|
        # If the rule had a block, the entire block defines the rule
        block = rule.instance_variable_get(:@serialized_block)
        if block&.is_a?(String)
          # evaluate the block which will add a new rule. Eval the block to re-add the rule
          eval(block.gsub("abilities.", ""))
          # since the block was evaled, not read from file, we will have to stash the string
          # version of the block in case we need to serialize it again.
          @rules.last.instance_variable_set(:@serialized_block, block)
        else
          # this rule has no block, just index it
          add_rule(rule)
        end
      end
    end
  end
end
