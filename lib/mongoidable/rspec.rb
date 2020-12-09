# frozen_string_literal: true

require "cancan"

load "mongoidable/rspec/controller_matchers.rb"
load "mongoidable/rspec/current_ability_controller_stub.rb"
load "mongoidable/rspec/exact_matcher.rb"
load "mongoidable/rspec/instance_variable_matcher.rb"

::RSpec.configure do |rspec_config|
  rspec_config.include Mongoidable::RSpec::ControllerMatchers, type: :controller
  rspec_config.prepend_before(:each) do |example|
    authorizes_controller if example.metadata[:authorizes_controller].present?
  end
end
