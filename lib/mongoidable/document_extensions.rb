# frozen_string_literal: true

module Mongoidable
  # Defines the embedded instance ability relationship
  module DocumentExtensions
    extend ActiveSupport::Concern

    included do
      embeds_many :instance_abilities, class_name: "Mongoidable::Ability"
    end

    class_methods do
      def _load(args)
        raw_attributes = Marshal.load(args)
        instantiate(raw_attributes)
      end
    end

    def _dump(*args, &block)
      Marshal.dump(raw_attributes, *args, &block)
    end
  end
end