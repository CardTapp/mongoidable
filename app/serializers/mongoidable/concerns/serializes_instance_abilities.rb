# frozen_string_literal: true

module Mongoidable
  module Concerns
  module SerializesInstanceAbilities
    extend ActiveSupport::Concern

    included do
      attribute(:instance_abilities) do
        object.instance_abilities.pluck(:id)
      end
    end
  end
end
  end