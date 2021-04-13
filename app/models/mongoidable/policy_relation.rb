# frozen_string_literal: true

module Mongoidable
  class PolicyRelation
    include Mongoid::Document
    include Mongoidable::Document

    field :required_data, type: Hash
    belongs_to :policy

    def add_inherited_abilities
      @abilities.merge(merge_abilities)
    end

    def merge_abilities
      policy_abilities = policy.instance_abilities.clone
      policy_abilities.each do |ability|
        next unless ability.extra.present?

        hash_attributes = ability.extra.first
        hash_attributes.each do |key, path|
          next unless path.include?("merge|")

          attribute_path = path.gsub("merge|", "")

          hash_attributes[key] = required_data.with_indifferent_access.dig(*attribute_path.split("."))
        end
      end
      policy_abilities
    end
  end
end
