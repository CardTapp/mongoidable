# frozen_string_literal: true

require "mongoid"
require "cancan"
module Mongoidable
  module Mongoid
    module Document
      extend ActiveSupport::Concern

      included do
        embeds_many :instance_abilities, class_name: "Mongoidable::Ability"

        after_create :current_abilities
        after_build :current_abilities
        after_initialize :current_abilities

        index({ _id: 1, "abilities.name": 1 }, { background: true, unique: true })

        def initialize(*args)
          super(*args)
          current_abilities
        end

        def add_instance_ability(*args)
          ability = parse_args(*args)
          instance_abilities << ability
          current_abilities
        end

        def remove_instance_ability(*args)
          ability = parse_args(*args)
          found_ability = instance_abilities.where(base_behavior: ability.base_behavior, action: ability.action, subject: ability.subject).first
          instance_abilities.delete(found_ability) if found_ability.present?
          current_abilities
        end

        def own_abilities
          @own_abilities = Mongoidable::Abilities.new
          instance_abilities.each do |ability|
            if ability.base_behavior
              @own_abilities.can(*ability.to_a)
            else
              @own_abilities.cannot(*ability.to_a)
            end
          end
          @own_abilities
        end

        def class_abilities
          self.class.class_abilities
        end

        def inherited_abilities
          sum = Mongoidable::Abilities.new
          self.class.inherits_from.each do |ancestor_relation|
            sum ||= Mongoidable::Abilities.new
            ancestor = send(ancestor_relation.name)
            next sum unless ancestor

            sum.merge(ancestor.inherited_abilities)
            sum.merge(ancestor.class_abilities)
            sum.merge(ancestor.own_abilities)
          end
          sum
        end

        def current_abilities
          inherited_abilities.merge(class_abilities).merge(own_abilities)
        end

        private

        def parse_args(*args)
          return args[0] if args.length == 1 && args[0].is_a?(Mongoidable::Ability)

          raise ArgumentError, "Invalid arguments" if args.length > 1 && args.length < 3

          Mongoidable::Ability.new(*args)
        end
      end

      class_methods do
        attr_accessor :inherits_from, :abilities

        def inherits_from
          @inherits_from ||= []
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

        def class_abilities
          @class_abilities ||= Mongoidable::Abilities.new
        end
      end
    end
  end
end

Mongoid::Document.include Mongoidable::Mongoid::Document