# frozen_string_literal: true

module Mongoidable
  # Default serializer for policies
  class AbilitySerializer < ActiveModel::Serializer
    attributes :action, :base_behavior, :extra
    attribute(:subject) do
      Mongoidable::ClassType.mongoize(object.subject)
    end
  end
end
