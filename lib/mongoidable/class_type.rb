# frozen_string_literal: true

module Mongoidable
  class ClassType
    class << self
      def mongoize(object)
        if object.nil?
          ""
        elsif object.is_a? Class
          object.name
        elsif object.is_a? Module
          object.name
        elsif Object.const_defined?(object)
          object
        else
          raise ArgumentError, "Unable to serialize #{object}"
        end
      rescue NameError
        raise ArgumentError, "Unable to serialize #{object}"
      end

      def demongoize(object)
        object == "" ? nil : object.constantize
      end

      def evolve(object)
        case object
          when Class then mongoize(object)
          when nil then ""
          else object
        end
      end
    end
  end
end