# frozen_string_literal: true

module Mongoidable
  # Contains all the logic required to manage static class abilities
  module ClassAbilities
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    class_methods do
      # The static abilities of this class and abilities inherited from base classes
      def define_abilities(&block)
        ability_definition << block.to_proc
      end

      def ability_definition
        @ability_definition ||= []
      end

      def ancestral_abilities
        result = superclass.respond_to?(:ancestral_abilities) ? superclass.ancestral_abilities : []
        result += ability_definition
        result
      end

      def inherits_from
        @inherits_from ||= superclass.respond_to?(:inherits_from) ? superclass.inherits_from.dup : []
      end

      def inherits_abilities_from(relation)
        inherits_from << { name: relation } if valid_singular_relation?(relation)
        inherits_from.uniq! { |item| item[:name] }
      end

      def inherits_abilities_from_many(relation, order_by, direction = :asc)
        inherits_from << { name: relation, order_by: order_by, direction: direction } if valid_many_relation?(relation)
        inherits_from.uniq! { |item| item[:name] }
      end

      private

      def valid_singular_relation?(relation_key)
        raise ArgumentError, "Could not find relation #{relation_key}" unless relation_exists?(relation_key)

        relation = relations[relation_key.to_s]
        raise ArgumentError, _("Attempt to use singular inheritance on many relation") unless singular_relation?(relation)

        true
      end

      def valid_many_relation?(relation_key)
        raise ArgumentError, "Could not find relation #{relation_key}" unless relation_exists?(relation_key)

        relation = relations[relation_key.to_s]
        raise ArgumentError "Attempt to use many inheritance on singular relation" if singular_relation?(relation)

        true
      end

      def relation_exists?(key)
        relations.key?(key.to_s)
      end

      def singular_relation?(relation)
        relation.relation.macro.to_s.exclude?("many")
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end