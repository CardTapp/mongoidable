# frozen_string_literal: true

require "cancan/rule"

module CanCan
  module RuleExtentions
    attr_reader :rule_source, :rule_type

    def initialize(base_behavior, action, subject, *extra_args, &block)
      @rule_source = extra_args.first&.delete(:rule_source)
      @rule_type = extra_args.first&.delete(:rule_type)
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
        block:         serialize_block(@block) }
    end

    def marshal_load(hash)
      @base_behavior = hash[:base_behavior]
      @actions = hash[:actions]
      @subjects = hash[:subjects]
      @attributes = hash[:attributes]
      @conditions = hash[:conditions]
      @rule_source = hash[:rule_source]
      @rule_type = hash[:rule_type]
      deserialize_block(hash[:block])
    end

    def serialize_block(block)
      return nil unless block_given?

      c = Class.new
      c.class_eval do
        define_method :serializable, block
      end
      s = Ruby2Ruby.translate(c, :serializable)
      s.sub(/^def \S+\(([^)]*)\)/, 'lambda { |\1|').sub(/end$/, "}")
    end

    def deserialize_block(block_string)
      return if block_string.blank?

      eval(block_string)
    end
  end
end

CanCan::Rule.prepend(CanCan::RuleExtentions)