# frozen_string_literal: true

require "active_model_serializers"
require "devise"
require "mongoid"
require "cancan"
require "cancan/model_adapters/active_record_adapter"
require "cancan/model_adapters/active_record_4_adapter"
require "cancan/model_adapters/active_record_5_adapter"
require "cancancan/mongoid"
require "cancancan_pub_sub"
require "memoist"
require "method_source"
require "ruby2js"
require "ruby2js/filter/return"
require "mongoidable/cancan/active_record_disabler"
require "mongoidable/rule"
require "mongoidable/ability_updater"
require "mongoidable/casl_hash"
require "mongoidable/casl_list"
require "mongoidable/class_abilities"
require "mongoidable/class_type"
require "mongoidable/policy_locator"
require "mongoidable/policy_relation_locator"
require "mongoidable/configuration"
require "mongoidable/current_ability"
require "mongoidable/document_extensions"
require "mongoidable/engine"
require "mongoidable/instance_abilities"
require "mongoidable/ability_provider"
require "mongoidable/providee_listener"
require "mongoidable/provider_listener"
require "mongoidable/services/abilities_updater"
require "mongoidable/services/policies_updater"
require "ruby2ruby"
module Mongoidable
  def self.configuration
    @configuration ||= Mongoidable::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end

require "mongoidable/document"