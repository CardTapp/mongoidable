# frozen_string_literal: true

module Mongoidable
  class Configuration
    attr_accessor :ability_class,
                  :context_module,
                  :load_path,
                  :serialize_ruby,
                  :serialize_js,
                  :test_mode

    def initialize
      @ability_class = Mongoidable::Ability
      @context_module = nil
      @load_path = "app/models/abilities/**/*.rb"
      @serialize_ruby = true
      @serialize_js = true
      @test_mode = false
    end
  end
end