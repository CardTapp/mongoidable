# frozen_string_literal: true

module Mongoidable
  # Policies are a grouping of policy_abilities which may be applied to other objects
  class Policy
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoidable::Document

    # TODO dynamic types list
    def self.possible_types
      %w[user organization vertical]
    end

    field :name, type: String
    field :description, type: String
    field :policy_type, type: String
    field :requires, type: Hash

    validates :name, presence: true
    # TODO dynamic types list 
    validates :name, uniqueness: { scope: :policy_type, case_sensitive: true }
    # TODO dynamic types list
    validates :policy_type, presence: true
    # TODO dynamic types list
    validates :policy_type, inclusion: { in: possible_types }

    include Mongoidable::Scopes::Policy

    def merge_attributes(attributes_hash)
      policy_abilities = instance_abilities.clone
      policy_abilities.each do |ability|
        next unless ability.extra.present?

        hash_attributes = ability.extra.first
        hash_attributes.each do |key, path|
          next unless path.include?("merge|")

          attribute_path = path.gsub("merge|", "")

          hash_attributes[key] = attributes_hash.with_indifferent_access.dig(*attribute_path.split("."))
        end
      end
      policy_abilities
    end
  end
end
