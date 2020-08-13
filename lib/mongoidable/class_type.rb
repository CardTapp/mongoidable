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
        elsif object.is_a? Symbol
          object.to_s
        elsif Object.const_defined?(object)
          object
        else
          raise ArgumentError, "Unable to serialize #{object}"
        end
      rescue NameError
        raise ArgumentError, "Unable to serialize #{object}"
      end

      def demongoize(object)
        if object == ""
          nil
        elsif object.classify.safe_constantize
          object.constantize
        else
          object.to_s.to_sym
        end
      end

      def evolve(object)
        mongoize(object)
      end
    end
  end
end