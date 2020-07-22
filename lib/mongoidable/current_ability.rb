# frozen_string_literal: true

module Mongoidable
  module CurrentAbility
    def current_ability
      parental_abilities.
          merge(self.class.abilities).
          merge(own_abilities)
    end
  end
end
