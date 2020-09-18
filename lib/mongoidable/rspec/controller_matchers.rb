require "rspec/expectations"

module Mongoidable
  module RSpec
    module ControllerMatchers
      extend ::RSpec::Matchers::DSL

      ::RSpec::Matchers.define :authorize do |can_subjects|
        failure_message do
          if @expected_date
            return "expected cookie to have date within #{@expected_range} of #{@expected_date}, got #{@actual_date}" if @expected_range

            return "expected cookie to have date #{@expected_date}, got #{@actual_date}"
          end
        end

        match do |controller|
          allow(controller).to receive(@controller_action) {}
          allow(controller.class).to receive(:__callbacks).and_return({})
          controller.class.define_callbacks :process_action

          CanCan::ControllerResource.add_before_action(controller.class, :authorize_resource, *(@authorize_args || []))

          verifiers = Array.wrap(can_subjects).map do |subject|
            matcher = ::RSpec::Mocks::Matchers::Receive.new(:authorize!, nil).with(@controller_action, subject)
            matcher.setup_expectation(controller)
          end

          if @through_action
            controller.params = ActionController::Parameters.new(@action_params)
            controller.send(@through_action)
          end

          send(@controller_method, @controller_action, params: @action_params)
        ensure
          verifiers
        end

        chain :for do |controller_method, controller_action, action_params = {}|
          @controller_method = controller_method
          @controller_action = controller_action
          @action_params = action_params
        end

        chain :with do |*authorize_args|
          @authorize_args = authorize_args
        end

        chain :through_action do |through_action|
          @through_action = through_action
        end

        chain :and do |through_action|
          @through_action = through_action
        end
      end

      def authorizes_controller
        allow(subject).to receive_message_chain(:current_ability, :authorize!).and_return(true)
      end
    end
  end
end