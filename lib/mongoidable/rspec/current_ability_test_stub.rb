# frozen_string_literal: true

module Mongoidable
  module RSpec
    class CurrentAbilityTestStub
      def initialize(identity)
        @identity = identity
      end

      def current_ability(_parent = nil)
        Mongoidable::RSpec::AbilitiesTestStub.new(@identity)
      end
    end
  end
end
