# frozen_string_literal: true

module Mongoidable
  class ClassType
    class << self
      def mongoize(object)
        if object.is_a?(Hash) && %w[type value].all? { |key| object.with_indifferent_access.key?(key) }
          object
        elsif object.is_a?(ActionController::Parameters) && %w[type value].all? { |key| object.key?(key) }
          object
        elsif object.nil?
          { type: "nil", value: nil }
        elsif object.is_a? Class
          { type: "class", value: object.name }
        elsif object.is_a? Module
          { type: "module", value: object.name }
        elsif object.is_a? String
          { type: "string", value: object }
        elsif object.is_a? Symbol
          { type: "symbol", value: object.to_s }
        else
          raise ArgumentError, "Unable to serialize #{object}"
        end
      rescue NameError
        raise ArgumentError, "Unable to serialize #{object}"
      end

      def demongoize(object)
        type, value = object.to_h.with_indifferent_access.values_at(:type, :value)
        case type
          when "nil"
            nil
          when "module", "class"
            value.classify.safe_constantize
          when "symbol"
            value.to_sym
          when "string"
            value.to_s
          else
            raise ArgumentError, "Unable to deserialize #{object}" unless type.nil? && value.nil?

            nil

        end
      end

      def evolve(object)
        mongoize(object)
      end
    end
  end
end