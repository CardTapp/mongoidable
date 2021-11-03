# frozen_string_literal: true

require "cancan/rule"

module CanCan
  module RuleExtentions
    attr_reader :rule_source, :rule_type
    attr_accessor :abilities, :serialized_block

    def initialize(base_behavior, action, subject, *extra_args, &block)
      extra_first_hash = extra_args.presence&.select { |arg| arg.respond_to?(:key?) }&.first || {}

      @rule_source = extra_first_hash&.delete(:rule_source)
      @rule_type = extra_first_hash&.delete(:rule_type)
      extra_args&.delete_if { |arg| arg.blank? }
      super
    end
  end
end

CanCan::Rule.prepend(CanCan::RuleExtentions)