# frozen_string_literal: true

module Mongoidable
  module RSpec
    class ExactMatcher
      def initialize(expected)
        @expected = expected
      end

      def ==(other)
        @expected == other
      end

      def ===(_other)
        false
      end

      def description
        "is always false if === is called"
      end
    end
  end
end