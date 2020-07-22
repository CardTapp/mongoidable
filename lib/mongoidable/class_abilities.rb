# frozen_string_literal: true

module Mongoidable
  module ClassAbilities
    extend ActiveSupport::Concern

    class_methods do
      def abilities
        @abilities ||= eval_class_abilities
        @abilities.eval_abilities
        @abilities
      end

      def eval_class_abilities
        ancestor_classes.dup.reverse.inject(Mongoidable::Abilities.new) do |sum, ancestor|
          ancestor.abilities.eval_abilities
          sum.merge ancestor.abilities
        end
      end

      def ancestor_classes
        @ancestor_classes ||= ancestors.filter do |ancestor|
          ancestor != self && ancestor.included_modules.include?(Mongoidable::ClassAbilities)
        end
      end

      # This needs to be evaluated each time due to the use of blocks in cancan rules
      def ancestral_abilities
        sum = Mongoidable::Abilities.new
        ancestor_classes.each do |ancestor_class|
          sum.merge(ancestor_class.abilities)
        end
        sum
      rescue StandardError => error
        error.to_s
      end
    end
  end
end