# frozen_string_literal: true

module Mongoidable
  class Configuration
    attr_accessor :cache_key_prefix,
                  :cache_ttl,
                  :context_module,
                  :enable_caching,
                  :serialize_ruby,
                  :serialize_js

    def initialize
      @cache_key_prefix = "Mongoidable"
      @cache_ttl = 60
      @context_module = nil
      @enable_caching = true
      @serialize_ruby = true
      @serialize_js = true
    end
  end
end