# frozen_string_literal: true

require "mongoid"
require "cancan"
require "cancan/model_adapters/active_record_adapter"
require "cancan/model_adapters/active_record_4_adapter"
require "cancan/model_adapters/active_record_5_adapter"
require "cancancan/mongoid"
require "memoist"
require "method_source"
require "ruby2js"
require "ruby2js/filter/return"

require "mongoidable/cancan/active_record_disabler"
require "mongoidable/rule"

require "mongoidable/casl_hash"
require "mongoidable/class_abilities"
require "mongoidable/class_type"
require "mongoidable/configuration"
require "mongoidable/current_ability"
require "mongoidable/document_extensions"
require "mongoidable/engine"
require "mongoidable/instance_abilities"
require "ruby2ruby"
module Mongoidable
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end

require "mongoidable/document"