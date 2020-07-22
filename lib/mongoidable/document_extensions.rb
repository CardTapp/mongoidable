# frozen_string_literal: true

module Mongoidable
  # Defines the embedded instance ability relationship
  module DocumentExtensions
    extend ActiveSupport::Concern

    included do
      embeds_many :instance_abilities, class_name: "Mongoidable::Ability"

      index({ _id: 1, "instance_abilities.name": 1 }, { background: true, unique: true })
    end
  end
end