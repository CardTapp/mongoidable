# frozen_string_literal: true

module Mongoidable
  # Policies are a grouping of policy_abilities which may be applied to other objects
  class Policy
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoidable::Document

    store_in collection: Mongoidable.configuration.policy_collection

    def self.possible_types
      @possible_types ||= []
    end

    field :name, type: String
    field :description, type: String
    field :owner_type, type: String
    field :requirements, type: Hash

    validates :name, presence: true
    validates :name, uniqueness: { scope: :owner_type, case_sensitive: true }
    validates :owner_type, presence: true
    validates :owner_type, inclusion: { in: possible_types }
  end
end
