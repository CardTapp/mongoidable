# frozen_string_literal: true

module Mongoidable
  module CurrentAbility
    def current_ability
      parental_abilities.
          merge(self.class.abilities).
          merge(own_abilities)
    rescue StandardError => error
      error.to_s
    end
  end
end
