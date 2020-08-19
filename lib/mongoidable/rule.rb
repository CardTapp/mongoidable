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
  end
end

CanCan::Rule.prepend(CanCan::RuleExtentions)