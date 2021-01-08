# frozen_string_literal: true

module Mongoidable
  class Configuration
    attr_accessor :ability_class,
                  :cache_key_prefix,
                  :cache_ttl,
                  :context_module,
                  :enable_caching,
                  :serialize_ruby,
                  :serialize_js,
                  :test_mode

    def initialize
      @ability_class = "Mongoidable::Ability"
      @cache_key_prefix = "Mongoidable"
      @cache_ttl = 60
      @context_module = nil
      @enable_caching = true
      @serialize_ruby = true
      @serialize_js = true
      @test_mode = false
    end
  end
end