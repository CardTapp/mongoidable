# frozen_string_literal: true

module Mongoidable
  # Default serializer for policies
  class PolicySerializer < ActiveModel::Serializer
    include Mongoidable::Concerns::SerializesInstanceAbilities
    include Mongoidable::Concerns::SerializesCaslAbilities

    attribute(:_id) { object.id.to_s }

    def attributes(*args)
      super(*args).reverse_merge(object.attributes.symbolize_keys)
    end
  end
end
