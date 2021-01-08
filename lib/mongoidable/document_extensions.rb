# frozen_string_literal: true

module Mongoidable
  # Defines the embedded instance ability relationship
  module DocumentExtensions
    extend ActiveSupport::Concern

    included do
      ability_class = Mongoidable.configuration.ability_class.constantize
      raise TypeError unless ability_class == Mongoidable::Ability || ability_class.superclass == Mongoidable::Ability

      embeds_many :instance_abilities, class_name: Mongoidable.configuration.ability_class

      after_find do
        instance_abilities.each { |ability| ability.parentize(self) }
      end
    end
  end
end