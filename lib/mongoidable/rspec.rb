# frozen_string_literal: true

require "cancan"
load "mongoidable/rspec/configuration.rb"
load "mongoidable/rspec/controller_matchers.rb"
load "mongoidable/rspec/current_ability_controller_stub.rb"
load "mongoidable/rspec/abilities_test_stub.rb"
load "mongoidable/rspec/exact_matcher.rb"
load "mongoidable/rspec/instance_variable_matcher.rb"

module Mongoidable
  module RSpec
    class << self
      def configuration
        @configuration ||= Mongoidable::RSpec::Configuration.new
      end

      def reset
        @configuration = Mongoidable::RSpec::Configuration.new
      end

      def configure
        yield(configuration)
      end
    end

    ::RSpec.configure do |rspec_config|
      rspec_config.include Mongoidable::RSpec::ControllerMatchers, type: :controller
      rspec_config.include Mongoidable::RSpec::ControllerMatchers, type: :controller

      rspec_config.prepend_before(:each) do |example|
        Mongoidable::RSpec.reset
        meta = example.metadata
        Mongoidable::RSpec.configuration.tap do |config|
          config.with_abilities = true if meta[:type] == :feature
          config.with_abilities = meta[:with_abilities] if meta.key?(:with_abilities) && config.with_abilities != true
          config.set_by_example(example, :default_can_ability_with) unless meta[:default_can_ability_with].nil?
          config.set_by_example(example, :default_cannot_ability_with) unless meta[:default_cannot_ability_with].nil?
          config.set_by_example(example, :default_abilities) unless meta[:default_abilities].nil?
        end
        authorizes_controller if meta[:authorizes_controller].present?
      end
    end
  end
end