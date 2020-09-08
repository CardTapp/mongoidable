require "rspec/expectations"

module Mongoidable
  module RSpec
    module ControllerMatchers
      extend ::RSpec::Matchers::DSL

      ::RSpec::Matchers.define :authorize do |can_subject|
        def callback_chain(controller)
          cancan_callback = controller._process_action_callbacks.detect do |callback|
            next if callback.raw_filter.is_a? Symbol

            callback.raw_filter.source_location.to_s.include?("cancan/controller_resource.rb")
          end
          new_callbacks = controller.__callbacks.keys.map { |key| [key, ActiveSupport::Callbacks::CallbackChain.new("test chain", {})] }.to_h
          new_callbacks[:process_action].append(cancan_callback)

          new_callbacks
        end

        failure_message do
          if @expected_date
            return "expected cookie to have date within #{@expected_range} of #{@expected_date}, got #{@actual_date}" if @expected_range

            return "expected cookie to have date #{@expected_date}, got #{@actual_date}"
          end
        end

        match do |controller|
          allow(controller).to receive(@controller_action) {}
          allow(controller).to receive(:__callbacks).and_return(callback_chain(controller))

          matcher = ::RSpec::Mocks::Matchers::Receive.new(:authorize!, nil).with(@controller_action, can_subject)
          verify = matcher.setup_expectation(controller)
          send(@controller_method, @controller_action, params: @action_params)
        ensure
          verify
        end

        chain :for do |controller_method, controller_action, action_params = {}|
          @controller_method = controller_method
          @controller_action = controller_action
          @action_params = action_params
        end
      end

      def authorizes(args)
        allow(subject).to receive_message_chain(:current_ability, :authorize!).with(*args).and_return(true)
      end
    end
  end
end