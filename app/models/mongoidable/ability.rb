# frozen_string_literal: true

module Mongoidable
  class Ability
    include ::Mongoid::Document

    attr_accessor :check_block

    field :action, type: String
    field :subject, type: String
    field :base_behavior, type: Boolean, default: true

    # TODO: Need to handle extra and block assignments
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