# frozen_string_literal: true

require "cancan/rule"

module CanCan
  module RuleExtentions
    attr_reader :rule_source, :rule_type
    attr_accessor :abilities, :serialized_block

    def initialize(base_behavior, action, subject, *extra_args, &block)
      @rule_source = extra_args.first&.delete(:rule_source)
      @rule_type = extra_args.first&.delete(:rule_type)
      @abilities = extra_args.first&.delete(:parent)
      extra_args.shift if extra_args.first && extra_args.first.empty?
      super
    end

    private

    def block_local_variables
      return {} unless @block

      local_variables = @block.binding.local_variables - [:abilities]
      local_variables.map do |variable_name|
        result = @block.binding.local_variable_get(variable_name)
        variable_value = { value: result }
        variable_value[:parent_model] = result.parent_model if result.respond_to?(:parent_model)
        [variable_name, variable_value]
      rescue TypeError => error
        raise TypeError, "While dumping #{variable_name} - #{error.message}"
      end.to_h
    end

    def marshal_dump
      Marshal.dump({ base_behavior: @base_behavior,
                     actions:       @actions,
                     subjects:      @subjects,
                     attributes:    @attributes,
                     conditions:    @conditions,
                     rule_source:   @rule_source,
                     rule_type:     @rule_type,
                     block:         @serialized_block || @block&.source&.strip,
                     block_locals:  block_local_variables })
    end

    def marshal_load(hash)
      hash = Marshal.load(hash)
      @base_behavior =    hash[:base_behavior]
      @actions =          hash[:actions]
      @subjects =         hash[:subjects]
      @attributes =       hash[:attributes]
      @conditions =       hash[:conditions]
      @rule_source =      hash[:rule_source]
      @rule_type =        hash[:rule_type]
      @serialized_block = hash[:block]
      @block_locals =     hash[:block_locals].map do |key, value|
        result = value[:value]
        parent = value[:parent_model]
        result.parent_model = parent if parent
        [key, result]
      end.to_h
      extend Mongoidable.configuration.context_module if Mongoidable.configuration.context_module
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