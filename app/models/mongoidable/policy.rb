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

    has_many :policy_relations, class_name: "Mongoidable::PolicyRelation"

    validates :name, presence: true
    # TODO dynamic types list 
    validates :name, uniqueness: { scope: :policy_type, case_sensitive: true }
    # TODO dynamic types list
    validates :policy_type, presence: true
    # TODO dynamic types list
    validates :policy_type, inclusion: { in: possible_types }
  end
end
