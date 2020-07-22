# frozen_string_literal: true

module Mongoidable
  module ParentAbilities
    extend ActiveSupport::Concern

    class_methods do
      def inherits_from
        unless @inherits_from.present?
          @inherits_from = ancestor_classes.dup.reverse.inject([]) { |sum, ancestor| sum + ancestor.inherits_from }
        end
        @inherits_from
      end

      def inherits_abilities_from(relation)
        inherits_from << validate_relation(relation)
        inherits_from.uniq!
      end

      def validate_relation(relation_key)
        raise ArgumentError, "Could not find relation #{relation_key}" unless relations.key?(relation_key.to_s)

        relation = relations[relation_key.to_s]
        raise ArgumentError, "Only singular relations are supported" if relation.relation.macro.to_s.include?("many")

        relations[relation_key.to_s]
      end
    end

    def parental_abilities
      sum = Mongoidable::Abilities.new
      self.class.inherits_from.each do |parent_relation|
        sum ||= Mongoidable::Abilities.new
        parent = send(parent_relation.name)
        next sum unless parent

        sum.merge(parent.current_ability)
      end
      sum
    end
  end
end