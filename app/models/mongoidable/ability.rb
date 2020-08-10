# frozen_string_literal: true

module Mongoidable
  # A mongoid document used to store adhoc abilities.
  class Ability
    include ::Mongoid::Document

    attr_accessor :check_block

    # The action being defined (:something)
    field :action, type: Symbol
    # The class or instance the ability is defined for
    field :subject, type: Mongoidable::ClassType
    # Is this a grant or a revocation
    field :base_behavior, type: Boolean, default: true
    # Extra arguments as defined by cancancan.
    field :extra, type: Array

    validates_presence_of :action
    validate :subject do |object|
      raise ArgumentError, ":subject cannot be blank" if object.subject.nil?
    end
    validates_presence_of :base_behavior

    embedded_in :instance_abilities

    def to_a
      [action, subject, extra]
    end
  end
end