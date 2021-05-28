# frozen_string_literal: true

module Mongoidable
  module Concerns
    module SerializesInstanceAbilities
      extend ActiveSupport::Concern

      included do
        has_many :instance_abilities do
          object.instance_abilities.map(&:id).map(&:to_s)
        end
      end
    end
  end
end