# frozen_string_literal: true

require "mongoid"
require "cancan"
require "cancan/model_adapters/active_record_5_adapter"
require "cancan/model_adapters/active_record_4_adapter"
require "cancancan/mongoid"

require "memoist"
require "mongoidable/active_record_disabler"
require "mongoidable/class_abilities"
require "mongoidable/class_type"
require "mongoidable/configuration"
require "mongoidable/current_ability"
require "mongoidable/document_extensions"
require "mongoidable/engine"
require "mongoidable/instance_abilities"

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