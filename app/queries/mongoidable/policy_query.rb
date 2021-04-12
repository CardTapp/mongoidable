# frozen_string_literal: true

module Mongoidable
    # Provides a policy finder for PoliciesController
    class PolicyQuery < SimpleDelegator
      include Mongoidable::Concerns::UpdatesAbilities
      extend Memoist

      attr_reader :authorized_user, :params

      def initialize(authorized_user, params)
        @authorized_user = authorized_user
        @params = params
        super(Mongoidable::Policy)
      end

      def object_for_index
        find_by(index_params)
      end

      def object_for_show
        find_by(find_params)
      end

      def object_for_create
        new(create_params)
      end

      def object_for_destroy
        find_by(find_params)
      end

      private

      def query_type
        Mongoidable::Policy
      end

      def index_params
        { policy_type: params[:policy_type] }
      end

      def create_params
        params.permit
      end

      def find_params
        {id: params[:id]}
      end

      def find_id
        {id: params.to_unsafe_hash[:id] }
      end

      memoize :object_for_index,
              :object_for_update,
              :find_params
    end
end