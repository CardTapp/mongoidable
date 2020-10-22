# frozen_string_literal: true

require "rspec/expectations"

module Mongoidable
  module RSpec
    module ControllerMatchers
      extend ::RSpec::Matchers::DSL

      class ControllerHelper < SimpleDelegator
        def initialize(obj, controller, authorize_pairs)
          super(obj)

          @controller = controller
          @authorize_pairs = authorize_pairs
        end

        def error_message
          "The #{controller.class.name} did not authenticate the actions #{authorize_pairs.map(&:first)} against the specified object(s)."
        end

        def process_action
          setup_controller

          matchers = authorization_matcher
          controller._run_process_action_callbacks

          matchers
        end

        private

        attr_reader :controller,
                    :authorize_pairs

        def authorization_matcher
          authorize_pairs.map do |authorize_action, authorized_object|
            matcher = receive(:authorize!).with(
                exact_match(authorize_action),
                exact_match(authorized_object)
              )
            matcher.setup_expectation(controller)
          end
        end

        def exact_match(value)
          return value if value.is_a?(Mongoidable::RSpec::InstanceVariableMatcher)

          Mongoidable::RSpec::ExactMatcher.new(value)
        end

        def setup_controller
          controller.params.merge! controller_params
          controller.params[:action]     = controller_action
          controller.params[:controller] = controller.class.name.underscore[0..-12]
          controller.set_response!(response)

          allow(controller).to receive(:action_name).and_return controller_action.to_s
          allow(controller).to receive(:authorize!)
          allow(controller).to receive(controller_action) {}

          setup_callbacks
        end

        def controller_action
          __getobj__.instance_variable_get(:@controller_action)
        end

        def controller_params
          __getobj__.instance_variable_get(:@controller_params)
        end

        def run_actions_named
          __getobj__.instance_variable_get(:@run_actions_named) || []
        end

        def setup_callbacks
          cancan_callbacks = controller._process_action_callbacks.filter do |callback|
            raw_filter = callback.raw_filter

            if raw_filter.is_a?(Symbol)
              run_actions_named.include?(raw_filter)
            else
              raw_filter.source_location.to_s.include?("cancan/controller_resource.rb")
            end
          end

          new_callbacks = { process_action: ActiveSupport::Callbacks::CallbackChain.new("test chain", {}) }
          new_callbacks[:process_action].append(*cancan_callbacks)

          allow(controller).to receive(:__callbacks).and_return(new_callbacks)
        end
      end

      # expect(controller).to authorize(authorization_action, authorization).
      #     for(:controller_action, controller_params = {}).
      #     [optional, multiple] with_variable(variable, instance_name = nil).
      #     [optional] after_action(action_name)
      ::RSpec::Matchers.define :authorize do |authorize_action, authorized_object|
        authorize_pairs = [[authorize_action, authorized_object]]
        failure_message do
          if @helper
            @helper.error_message
          else
            "A disasterous error occured while preparing the matcher"
          end
        end

        match do |controller|
          @helper = Mongoidable::RSpec::ControllerMatchers::ControllerHelper.new(self, controller, authorize_pairs)

          verifiers = @helper.process_action
        ensure
          verifiers
        end

        chain :for do |controller_action, controller_params = {}|
          @controller_action = controller_action
          @controller_params = controller_params
        end

        chain :run_actions do |*filter_name|
          @run_actions_named = Array.wrap(filter_name)
        end

        chain :and do |new_action, new_object|
          authorize_pairs << [new_action, new_object]
        end
      end

      def authorizes_controller
        def subject.current_ability
          Mongoidable::RSpec::CurrentAbilityControllerStub.new(super)
        end
      end

      def instance_variable(variable_name)
        Mongoidable::RSpec::InstanceVariableMatcher.new(variable_name, subject)
      end
    end
  end
end