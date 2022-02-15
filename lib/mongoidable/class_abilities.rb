# frozen_string_literal: true

module Mongoidable
  # Contains all the logic required to manage static class abilities
  module ClassAbilities
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    class_methods do
      extend Memoist

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

      def accepts_policies(as:)
        embeds_many as, class_name: "Mongoidable::PolicyRelation", after_add: :renew_policies, after_remove: :renew_policies

        Mongoidable::PolicyRelation.embedded_in as
        Mongoidable::Policy.possible_types.concat([name.downcase]).uniq!
        inherits_abilities_from_many as, :id
      end

      def inherits_abilities_from(relation_name)
        return unless valid_singular_relation?(relation_name)

        trackable = { name: relation_name, type: :singular }
        define_provider_relation(relations[relation_name].class_name.constantize)
        inherits_from << trackable
        inherits_from.uniq! { |item| item[:name] }
      end

      def inherits_abilities_from_many(relation, order_by, direction = :asc)
        return unless valid_many_relation?(relation)

        trackable = { name: relation, order_by: order_by, direction: direction, type: :many }
        inherits_from << trackable
        inherits_from.uniq! { |item| item[:name] }
      end

      def define_provider_relation(parent_klass)
        relation_name = "#{name.downcase}_provided_abilities".to_sym
        Mongoidable::Ability.embedded_in(relation_name)
        parent_klass.embeds_many relation_name,
                                 class_name:   Mongoidable.configuration.ability_class,
                                 after_add:    :renew_provided_abilities,
                                 after_remove: :renew_provided_abilities do
          def update_ability(**attributes)
            Mongoidable::AbilityUpdater.new(parent_document, parent_document.send(association.name), attributes).call
            parent_document.renew_abilities(types: :instance)
          end
        end
      end

      def before_abilities(type, &block)
        before_callbacks[type] << block
      end

      def after_abilities(type, &block)
        after_callbacks[type] << block
      end

      def after_callbacks
        @after_callbacks ||= { inherited: [], provided: [], ancestral: [], instance: [] }
      end

      def before_callbacks
        @before_callbacks ||= { inherited: [], provided: [], ancestral: [], instance: [] }
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
        [Mongoid::Association::Referenced::HasOne,
         Mongoid::Association::Referenced::BelongsTo].any? do |singleton_class|
          relation.is_a?(singleton_class)
        end
      end

      memoize :ancestral_abilities
    end
    # rubocop:enable Metrics/BlockLength
  end
end