# frozen_string_literal: true

module Mongoidable
  module RSpec
    class InstanceVariableMatcher
      def initialize(variable_name, subject)
        @variable_name = variable_name
        @subject = subject
      end

      delegate :==, to: :variable_value

      def ===(_other)
        false
      end

      def description
        "compares a controllers instance variable to the actual value"
      end

      def variable_value
        @subject.instance_variable_get(:"@#{@variable_name}")
      end
    end
  end
end