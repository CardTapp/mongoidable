# frozen_string_literal: true

module CanCan
  class Rule
    def with_scope?
      false
    end
  end

  module ModelAdapters
    class ActiveRecord4Adapter
      def self.for_class?(_)
        false
      end
    end

    class ActiveRecord5Adapter
      def self.for_class?(_)
        false
      end
    end
  end
end
