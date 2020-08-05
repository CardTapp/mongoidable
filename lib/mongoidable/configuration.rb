# frozen_string_literal: true

module Mongoidable
  class Configuration
    attr_accessor :context_module

    def initialize
      @context_module = nil
    end
  end
end