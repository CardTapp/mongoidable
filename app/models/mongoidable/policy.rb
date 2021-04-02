# frozen_string_literal: true

module Mongoidable
  # Policies are a grouping of policy_abilities which may be applied to other objects
  # rubocop:disable Metrics/ClassLength:
  class Policy
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoidable::Document

    #TODO
    def self.possible_types
      %w[user organization vertical]
    end

    field :name, type: String
    field :description, type: String
    field :type, type: String

    validates_presence_of :name
    #TODO
    validates_uniqueness_of :name, scope: :type, case_sensitive: true
    #TODO
    validates_presence_of :type
    #TODO
    validates_inclusion_of :type, in: possible_types

    include Mongoidable::Scopes::Policy

    def merge_attributes(document)
      # TODO: This should accept a hash of attributes. Example { user: user_attributes, organization: organization_attributes}
      # Then in the merge it should choose the right hash key depending on the Ability type. Organization policy_abilities user organization key etc.
      document_attributes = document.attributes

      policy_abilities = instance_abilities.clone
      policy_abilities.each do |ability|
        next unless ability.extra.present?

        hash_attributes = ability.extra.first
        hash_attributes.each do |key, path|
          hash_attributes[key] = path.to_s.split(".").reduce(document_attributes) { |hash, att_key| hash[att_key] }
        end
      end
      policy_abilities
    end
  end
end
# rubocop:enable Metrics/ClassLength:
