# frozen_string_literal: true

module Mongoidable
  # Defines the embedded instance ability relationship
  module DocumentExtensions
    extend ActiveSupport::Concern

    included do
      ability_class = Mongoidable.configuration.ability_class
      raise TypeError, "Mongoidable::Document can only be included in a Mongoid::Document" unless
        ability_class.constantize.ancestors.map(&:to_s).include?(Mongoidable::Ability.name)

      embeds_many :instance_abilities, class_name: Mongoidable.configuration.ability_class, after_add: :renew_instance_abilities,
after_remove: :renew_instance_abilities do
        def update_ability(**attributes)
          Mongoidable::AbilityUpdater.new(parent_document, attributes).call
          parent_document.renew_abilities
        end
      end

      after_find do
        renew_abilities
        instance_abilities.each { |ability| ability.parentize(self) }
      end

      def renew_instance_abilities(_relation = nil)
        @renew_instance_abilities = true
        renew_abilities
      end
    end
  end
end