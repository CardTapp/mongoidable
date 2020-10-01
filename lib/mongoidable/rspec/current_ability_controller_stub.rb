# frozen_string_literal: true

module Mongoidable
  module RSpec
    class CurrentAbilityControllerStub < SimpleDelegator
      def authorize!(*_args)
        true
      end
    end
  end
end
