# frozen_string_literal: true

module Mongoidable
  # Defines the embedded instance ability relationship
  module DocumentExtensions
    extend ActiveSupport::Concern

    included do
      embeds_many :instance_abilities, class_name: "Mongoidable::Ability"

      after_find do
        instance_abilities.each { |ability| ability.parentize(self) }
      end
    end
  end
end