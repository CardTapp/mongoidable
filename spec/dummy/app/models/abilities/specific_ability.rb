# frozen_string_literal: true

module Mongoidable
  class SpecificAbility < Mongoidable::Ability
    def initialize(**args)
      super base_behavior: true, action: :specific_ability, subject: :specific_subject, extra: []
    end

    after_destroy :raise_error

    def self.ability
      :specific_ability
    end

    def self.valid_for?(parent_class)
      parent_class == User
    end

    private

    def raise_error
      raise "Testing that destroy is called"
    end
  end
end