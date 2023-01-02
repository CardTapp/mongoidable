# frozen_string_literal: true

require "cancan/rule"

module CanCan
  module RuleExtentions
    attr_reader :rule_source, :rule_type
    attr_accessor :abilities, :serialized_block

    def initialize(base_behavior, action, subject, *extra_args, &block)
      extra_first_hash = Mongoidable::Ability.attributes_and_conditions(extra_args)[1].first || {}

      @rule_source = extra_first_hash&.delete(:rule_source)
      @rule_type = extra_first_hash&.delete(:rule_type)

      extra_args.delete_if(&:blank?)

      super
    end
  end
end

CanCan::Rule.prepend(CanCan::RuleExtentions)