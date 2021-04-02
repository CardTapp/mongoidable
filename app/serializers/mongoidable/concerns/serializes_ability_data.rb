# frozen_string_literal: true

module Mongoidable
module Concerns
  module SerializesAbilityData
    extend ActiveSupport::Concern

    included do
      attribute(:ability_data) do
        instance_abilities = object.instance_abilities
        Hash[instance_abilities.filter_map do |ability|
          data = ability.serialize_data
          next if data.blank?

          [ability.class.ability, data]
        end]
      end
    end
  end
end
end