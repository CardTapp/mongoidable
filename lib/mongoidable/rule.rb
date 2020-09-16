# frozen_string_literal: true

require "base64"
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
      local_variables = @block.binding.local_variables - [:abilities]
      local_variables = local_variables.map do |variable_name|
        value = Base64.encode64(Marshal.dump(@block.binding.local_variable_get(variable_name)))
        [variable_name, value]
      end.to_h
      { base_behavior: @base_behavior,
        actions:       @actions,
        subjects:      @subjects,
        attributes:    @attributes,
        conditions:    @conditions,
        rule_source:   @rule_source,
        rule_type:     @rule_type,
        block:         @serialized_block || @block&.source&.strip,
        block_locals:  local_variables }
    end

    def marshal_load(hash)
      @base_behavior =    hash[:base_behavior]
      @actions =          hash[:actions]
      @subjects =         hash[:subjects]
      @attributes =       hash[:attributes]
      @conditions =       hash[:conditions]
      @rule_source =      hash[:rule_source]
      @rule_type =        hash[:rule_type]
      @serialized_block = hash[:block]
      @block_locals =     hash[:block_locals].each do |key, value|
        hash[:block_locals][key] = Marshal.load(Base64.decode64(value))
      end
    end

    def method_missing(method, *args, &block)
      if @block_locals.key?(method)
        @block_locals[method]
      else
        super
      end
    end
  end
end

CanCan::Rule.prepend(CanCan::RuleExtentions)