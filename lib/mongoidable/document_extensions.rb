# frozen_string_literal: true

module Mongoidable
  # Defines the embedded instance ability relationship
  module DocumentExtensions
    extend ActiveSupport::Concern

    included do
      ability_class = Mongoidable.configuration.ability_class
      raise TypeError, "Mongoidable::Document can only be included in a Mongoid::Document" unless
        ability_class.constantize.ancestors.map(&:to_s).include?(Mongoidable::Ability.name)

      embeds_many :instance_abilities, class_name: Mongoidable.configuration.ability_class, after_add: :renew_abilities,
after_remove: :renew_abilities do
        def update_ability(**attributes)
          Mongoidable::AbilityUpdater.new(parent_document, attributes).call
          parent_document.renew_abilities
        end
      end
      relations_dirty_tracking_options[:only] << "instance_abilities"
      relations_dirty_tracking_options[:enabled] = true

      after_find do
        renew_abilities
        instance_abilities.each { |ability| ability.parentize(self) }
      end
    end
  end
end