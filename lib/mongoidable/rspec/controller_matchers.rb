require "rspec/expectations"

module Mongoidable
  module RSpec
    module ControllerMatchers
      extend ::RSpec::Matchers::DSL

      class ControllerHelper < SimpleDelegator
        def initialize(obj, controller, authorize_action, authorized_object)
          super(obj)

          @controller        = controller
          @authorize_action  = authorize_action
          @authorized_object = authorized_object
        end

        def error_message
          "The #{controller.class.name} did not authenticate the action #{authorize_action} against the specified object."
        end

        def run_callbacks
          setup_controller

          matchers = [authorization_matcher]

          loaded_matcher

          matchers
        end

        private

        attr_reader :controller,
                    :authorize_action,
                    :authorized_object

        def loaded_matcher
          return unless and_load_instance

          expect(controller.instance_variable_get("@#{and_load_instance_name}")).to be
        end

        def authorization_matcher
          authorize_callbacks.each do |callback|
            callback.call(controller)
          end

          matcher = have_received(:authorize!).with(authorize_action, authorized_object)
          matcher.setup_expectation(controller)

          matcher
        end

        def setup_controller
          controller.params.merge! controller_params

          controller.params[:action]     = controller_action
          controller.params[:controller] = controller.class.name.underscore[0..-12]
          allow(controller).to receive(:action_name).and_return controller_action.to_s

          set_controller_instance_variables

          allow(controller).to receive(:authorize!)
        end

        def and_load_instance
          __getobj__.instance_variable_get(:@and_load_instance)
        end

        def and_load_instance_name
          __getobj__.instance_variable_get(:@and_load_instance_name) || controller_variable_name
        end

        def controller_action
          __getobj__.instance_variable_get(:@controller_action)
        end

        def controller_params
          __getobj__.instance_variable_get(:@controller_params)
        end

        def after_filter_name
          __getobj__.instance_variable_get(:@after_filter_name)
        end

        def set_controller_instance_variables
          return if instance_variables.blank?

          instance_variables.each do |variable_name, use_value|
            variable_name ||= controller_variable_name
            controller.instance_variable_set("@#{variable_name}", use_value)
          end
        end

        def instance_variables
          __getobj__.instance_variable_get(:@instance_variables)
        end

        def controller_variable_name
          controller.class.name[0..-11].demodulize.singularize.underscore
        end

        def authorize_callbacks
          found_filter = after_filter_name.blank?

          @authorize_callbacks ||= controller._process_action_callbacks.each_with_object([]) do |action, array|
            filter = action.raw_filter

            found_filter ||= filter == after_filter_name && action_is_called?(action)

            next unless found_filter
            next unless filter.is_a?(Proc)
            next unless filter.source_location.to_s.include?("cancan/controller_resource.rb")
            next unless action_is_called?(action)

            array << filter
          end
        end

        def action_is_called?(action)
          Array.wrap(action.instance_variable_get(:@if)).all? { |ifcall| ifcall.call(controller) }
        end
      end

      # expect(controller).to authorize(authorization_action, authorization).
      #     for(:controller_action, controller_params = {}).
      #     [optional, multiple] with_variable(variable, instance_name = nil).
      #     [optional] after_action(action_name)
      ::RSpec::Matchers.define :authorize do |authorize_action, authorized_object|
        failure_message do
          if @helper
            @helper.error_message
          else
            "A disasterous error occured while preparing the matcher"
          end
        end

        match do |controller|
          @helper = Mongoidable::RSpec::ControllerMatchers::ControllerHelper.new(self, controller, authorize_action, authorized_object)

          verifiers = @helper.run_callbacks
        ensure
          verifiers
        end

        chain :for do |controller_action, controller_params = {}|
          @controller_action = controller_action
          @controller_params = controller_params
        end

        chain :with_variable do |variable, instance_name = nil|
          @instance_variables                ||= {}
          @instance_variables[instance_name] = variable
        end

        chain :after_action do |filter_name|
          @after_filter_name = filter_name
        end
      end

      def authorizes_controller
        allow(subject).to receive_message_chain(:current_ability, :authorize!).and_return(true)
      end
    end
  end
end