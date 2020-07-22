# frozen_string_literal: true

module Mongoidable
  # Contains all the logic required to manage static class abilities
  module ClassAbilities
    extend ActiveSupport::Concern

    class_methods do
      # The static abilities of this class and abilities inherited from base classes
      def abilities
        @abilities ||= eval_class_abilities
        @abilities.eval_abilities
        @abilities
      end

      # Evaluate the definition block on base classes and return an aggregate ability.
      def eval_class_abilities
        ancestor_classes.dup.reverse.reduce(Mongoidable::Abilities.new) do |sum, ancestor|
          ancestor.abilities.eval_abilities
          sum.merge ancestor.abilities
        end
      end

      # Determine base classes which may also have ability defintions
      def ancestor_classes
        @ancestor_classes ||= ancestors.filter do |ancestor|
          ancestor != self && ancestor.included_modules.include?(Mongoidable::ClassAbilities)
        end
      end
    end
  end
end