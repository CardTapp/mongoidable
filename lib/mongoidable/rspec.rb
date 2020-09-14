# frozen_string_literal: true

require "cancan"
load "mongoidable/rspec/configuration.rb"
load "mongoidable/rspec/controller_matchers.rb"
load "mongoidable/rspec/abilities_test_stub.rb"

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

    ::RSpec.configure do |config|
      config.include Mongoidable::RSpec::ControllerMatchers, type: :controller

      config.prepend_before(:each) do |example|
        Mongoidable::RSpec.reset
        meta = example.metadata
        Mongoidable::RSpec.configuration.with_abilities = true if meta[:with_abilities] || meta[:type] == :feature
        Mongoidable::RSpec.configuration.set_by_example(example, :default_can_ability_with) unless meta[:default_can_ability_with].nil?
        Mongoidable::RSpec.configuration.set_by_example(example, :default_cannot_ability_with) unless meta[:default_cannot_ability_with].nil?
        Mongoidable::RSpec.configuration.set_by_example(example, :default_abilities) unless meta[:default_abilities].nil?

        authorizes_controller if meta[:authorizes_controller].present?
      end
    end
  end
end