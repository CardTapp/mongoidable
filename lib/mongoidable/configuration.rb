# frozen_string_literal: true

module Mongoidable
  class Configuration
    attr_accessor :ability_class,
                  :cache_key_prefix,
                  :cache_ttl,
                  :context_module,
                  :enable_caching,
                  :load_path,
                  :policy_collection,
                  :policy_class,
                  :policy_locator,
                  :policy_query,
                  :policy_relation_locator,
                  :serialize_ruby,
                  :serialize_js,
                  :test_mode

    def initialize
      @ability_class = "Mongoidable::Ability"
      @cache_key_prefix = "Mongoidable"
      @cache_ttl = 60
      @context_module = nil
      @enable_caching = true
      @load_path = "app/models/abilities/**/*.rb"
      @policy_collection = :mongoidable_policies
      @policy_class = "Mongoidable::Policy"
      @policy_locator = "Mongoidable::PolicyLocator"
      @policy_query = "Mongoidable::PolicyQuery"
      @policy_relation_locator = "Mongoidable::PolicyRelationLocator"
      @serialize_ruby = true
      @serialize_js = true
      @test_mode = false
    end
  end
end