# frozen_string_literal: true

module Mongoidable
  class Configuration
    attr_accessor :context_module, :serialize_ruby, :serialize_js, :test_mode

    def initialize
      @context_module = nil
      @serialize_ruby = true
      @serialize_js = true
      @test_mode = false
    end
  end
end