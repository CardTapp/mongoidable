# frozen_string_literal: true

module Mongoidable
  # A mongoid document used to store abilities a model can provide to another.
  class ProvidedAbility
    extend Memoist
    include ::Mongoid::Document

    # The action being defined (:something)
    field :action, type: Symbol
    # The class or instance the ability is defined for
    field :subject, type: Mongoidable::ClassType
    # Is this a grant or a revocation
    field :base_behavior, type: Boolean, default: true
    # Extra arguments as defined by cancancan.
    field :extra, type: Array

    def to_args
      attributes.except("_id")
    end

    def to_inverse_args
      result = to_args
      result["base_behavior"] = !result["base_behavior"]
      result
    end
  end
end
