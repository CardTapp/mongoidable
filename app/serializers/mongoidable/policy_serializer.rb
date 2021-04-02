# frozen_string_literal: true

module Mongoidable
    # Default serializer for policies
    class PolicySerializer < ActiveModel::Serializer
      include Concerns::SerializesInstanceAbilities

      attributes :_id, :name, :description, :type
    end
end
