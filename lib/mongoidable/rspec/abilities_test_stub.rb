# frozen_string_literal: true

module Mongoidable
  module RSpec
    class AbilitiesTestStub
      include ::CanCan::Ability
      include Mongoidable::CaslList
      attr_reader :ability_source
      attr_accessor :rule_type, :parent

      def initialize(ability_source, parent)
        @ability_source = ability_source
        @rule_type = :adhoc
        @parent = parent
      end

      def can?(action, subject, _attribute = nil, *_extra_args)
        if config.with_abilities
          abilities.can? action, subject
        else
          value = config.default_can_ability_with
          raise "Test ability configuration missing" unless !value.nil? || test_abilities_configured?

          return value unless value.nil?

          raise "Invalid ability configuration"
        end
      end

      def cannot?(*args)
        if config.with_abilities
          !abilities.can? action, subject
        else
          value = config.default_cannot_ability_with
          raise "Test ability configuration missing" unless !value.nil? || test_abilities_configured?

          return value unless value.nil?

          raise "Invalid ability configuration"
        end
      end

      def cannot(action = nil, subject = nil, *attributes_and_conditions, &block)
        # in test mode definitions are completely ignored
      end

      def can(action = nil, subject = nil, *attributes_and_conditions, &block)
        # in test mode definitions are completely ignored
      end

      private

      def abilities
        abilities = Mongoidable::Abilities.new(ability_source, parent)
        config.with_abilities.each do |action, subject|
          abilities.can action, subject
        end
        abilities
      end

      def test_abilities_configured?
        !config.default_can_ability_with.nil? || !config.with_abilities.nil?
      end

      def config
        Mongoidable::RSpec.configuration
      end
    end
  end
end
