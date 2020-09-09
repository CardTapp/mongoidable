# frozen_string_literal: true

module Mongoidable
  module RSpec
    class Configuration
      attr_accessor :with_abilities, :default_can_ability_with, :default_cannot_ability_with, :stub_ability_rules

      def initialize
        @with_abilities = nil
        @default_can_ability_with = nil
        @default_cannot_ability_with = nil
        @stub_ability_rules = nil
      end

      def default_abilities=(value)
        @default_can_ability_with = value
        @default_cannot_ability_with = !value

      end
      def set_by_example(example, key)
        value = example.metadata[key]
        value = ActiveModel::Type::Boolean.new.cast(value)
        Mongoidable::RSpec.configuration.send("#{key}=".to_sym, value)
      end
    end
  end
end
