# frozen_string_literal: true

require "cancan/rule"

module CanCan
  module RuleExtentions
    attr_reader :rule_source, :rule_type, :abilities

    def initialize(base_behavior, action, subject, *extra_args, &block)
      @rule_source = extra_args.first&.delete(:rule_source)
      @rule_type = extra_args.first&.delete(:rule_type)
      @abilities = extra_args.first&.delete(:parent)
      extra_args.shift if extra_args.first&.empty?
      super
    end

    private

    def marshal_dump
      { base_behavior: @base_behavior,
        actions:       @actions,
        subjects:      @subjects,
        attributes:    @attributes,
        conditions:    @conditions,
        rule_source:   @rule_source,
        rule_type:     @rule_type,
        block:         @block&.source&.strip }
    end

    def marshal_load(hash)
      @base_behavior = hash[:base_behavior]
      @actions = hash[:actions]
      @subjects = hash[:subjects]
      @attributes = hash[:attributes]
      @conditions = hash[:conditions]
      @rule_source = hash[:rule_source]
      @rule_type = hash[:rule_type]
      @block = hash[:block]
    end
  end
end

CanCan::Rule.prepend(CanCan::RuleExtentions)