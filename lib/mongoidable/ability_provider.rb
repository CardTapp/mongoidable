# frozen_string_literal: true

module Mongoidable
  module AbilityProvider
    extend Memoist
    extend ActiveSupport::Concern

    class_methods do
      extend Memoist

      def provided_ability_relations
        @provided_ability_relations ||= superclass.respond_to?(:provided_ability_relations) ? superclass.provided_ability_relations.dup : []
      end

      def provides_abilities_to(relation_name)
        return unless relation_exists?(relation_name)
        return if self == Mongoidable::PolicyRelation

        Mongoidable::ProviderListener.new(relations[relation_name]).call
        Mongoidable::ProvideeListener.new(relations[relation_name]).call
      end
    end

    def provided_abilities(relation)
      process_instance_abilities(send(relation))
    end

    memoize :provided_abilities
  end
end
