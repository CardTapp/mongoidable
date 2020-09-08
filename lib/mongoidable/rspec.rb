# frozen_string_literal: true

load "mongoidable/rspec/configuration.rb"
load "mongoidable/rspec/controller_matchers.rb"
load "mongoidable/rspec/current_ability_test_stub.rb"
load "mongoidable/rspec/abilities_test_stub.rb"
load "mongoidable/rspec/current_ability.rb"

Mongoidable::CurrentAbility.include Mongoidable::RSpec::CurrentAbility

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

      config.before(:each) do |example|
        if defined?(Mongoidable::RSpec)
          Mongoidable::RSpec.reset
          meta = example.metadata
          Mongoidable::RSpec.configuration.with_abilities = true if meta[:with_abilities] || meta[:type] == :feature
          Mongoidable::RSpec.configuration.set_by_example(example, :default_can_ability_with) unless meta[:default_can_ability_with].nil?
          Mongoidable::RSpec.configuration.set_by_example(example, :default_cannot_ability_with) unless meta[:default_cannot_ability_with].nil?
        end
      end
    end
  end
end