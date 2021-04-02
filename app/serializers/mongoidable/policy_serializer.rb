# frozen_string_literal: true

module Mongoidable
  # Default serializer for policies
  class PolicySerializer < ActiveModel::Serializer
    include Mongoidable::Concerns::SerializesInstanceAbilities
    def attributes(*_args)
      object.attributes.symbolize_keys
    end
  end
end
