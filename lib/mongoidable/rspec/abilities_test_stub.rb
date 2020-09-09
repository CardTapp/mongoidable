# frozen_string_literal: true

module Mongoidable
  module RSpec
    class AbilitiesTestStub
      include CanCan::Ability
      attr_reader :ability_source
      attr_accessor :rule_type

      def initialize(ability_source)
        @ability_source = ability_source
        @rule_type = :adhoc
      end

      def can?(_action, _subject, _attribute = nil, *_extra_args)
        value = config.default_can_ability_with
        raise "Test ability configuration missing" unless !value.nil? || test_abilities_configured?

        return value unless value.nil?

        raise "Invalid ability configuration"
      end

      def cannot?(*_args)
        value = Mongoidable::RSpec.configuration.default_cannot_ability_with
        raise "Test ability configuration missing" unless !value.nil? || test_abilities_configured?

        return value unless value.nil?

        raise "Invalid ability configuration"
      end

      def cannot(action = nil, subject = nil, *attributes_and_conditions, &block)
        # in test mode definitions are completely ignored
      end

      def can(action = nil, subject = nil, *attributes_and_conditions, &block)
        # in test mode definitions are completely ignored
      end

      private

      def test_abilities_configured?
        !config.default_can_ability_with.nil? || !config.with_abilities.nil?
      end

      def config
        Mongoidable::RSpec.configuration
      end
    end
  end
end
