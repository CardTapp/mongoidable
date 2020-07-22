# frozen_string_literal: true

module Mongoidable
  module DocumentExtensions
    extend ActiveSupport::Concern

    included do
      embeds_many :instance_abilities, class_name: "Mongoidable::Ability"

      # after_create :current_ability
      # after_build :current_ability
      # after_initialize :current_ability

      index({ _id: 1, "instance_abilities.name": 1 }, { background: true, unique: true })
    end
  end
end