# frozen_string_literal: true

module Mongoidable
  module RSpec
    module CurrentAbility
      def initialize(attrs = nil)
        super(attrs)
        if defined?(Mongoidable::RSpec) && !Mongoidable::RSpec.configuration.with_abilities
          @test_stub = Mongoidable::RSpec::CurrentAbilityTestStub.new(mongoidable_identity)
          extend SingleForwardable
          def_delegator :@test_stub, :current_ability
        end
      end
    end
  end
end
