# frozen_string_literal: true

module Mongoidable
  # Contains all the logic required to manage static class abilities
  module ClassAbilities
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    class_methods do
      # The static abilities of this class and abilities inherited from base classes
      def define_abilities(&block)
        @ability_definition = block.to_proc
      end

      def ability_definition
        @ability_definition
      end

      def ancestral_abilities
        result = superclass.respond_to?(:ancestral_abilities) ? superclass.ancestral_abilities : []
        result << ability_definition if ability_definition.present?
        result
      end

      def inherits_from
        @inherits_from ||= superclass.respond_to?(:inherits_from) ? superclass.inherits_from.dup : []
      end

      def inherits_abilities_from(relation)
        inherits_from << validate_relation(relation)
        inherits_from.uniq!
      end

      private

      def validate_relation(relation_key)
        raise ArgumentError, "Could not find relation #{relation_key}" unless relation_exists?(relation_key)

        relation = relations[relation_key.to_s]
        raise ArgumentError, "Only singular relations are supported" unless singular_relation?(relation)

        relations[relation_key.to_s]
      end

      def relation_exists?(key)
        relations.key?(key.to_s)
      end

      def singular_relation?(relation)
        !relation.relation.macro.to_s.include?("many")
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end