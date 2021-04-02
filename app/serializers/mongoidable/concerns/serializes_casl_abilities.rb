# frozen_string_literal: true

module Mongoidable
  module Concerns
    module SerializesCaslAbilities
      extend ActiveSupport::Concern

      included do
        attribute(:abilities) { object.current_ability.to_casl_list }
      end
    end
  end
end