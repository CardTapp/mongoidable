# frozen_string_literal: true

module Mongoidable
  # A mongoid document used to store adhoc abilities.
  class Ability
    include ::Mongoid::Document

    attr_accessor :check_block

    # The action being defined (:something)
    field :action, type: Symbol
    # The class or instance the ability is defined for
    field :subject, type: String
    # Is this a grant or a revocation
    field :base_behavior, type: Boolean, default: true
    # Extra arguments as defined by cancancan.
    field :extra, type: Array

    validates_presence_of :action
    validates_presence_of :subject
    validates_presence_of :base_behavior

    def initialize(*args)
      if args.nil?
        nil
      elsif args.first&.is_a?(Hash)
        super(*args)
      else
        super(
            base_behavior: args[0],
            action:        args[1],
            subject:       args[2],
            extra:         args[3]
        )
      end
    end

    def subject
      att_value = attributes["subject"]
      att_value&.classify&.safe_constantize || att_value
    end

    def to_a
      [action, subject, extra]
    end
  end
end