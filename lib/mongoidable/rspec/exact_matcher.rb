# frozen_string_literal: true

module Mongoidable
  module RSpec
    class ExactMatcher
      def initialize(expected)
        @expected = expected
      end

      def ==(value)
        @expected == value
      end

      def ===(value)
        false
      end

      def description
        "is always false if === is called"
      end
    end
  end
end