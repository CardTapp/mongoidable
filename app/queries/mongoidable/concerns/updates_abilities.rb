# frozen_string_literal: true

module Mongoidable
  module Concerns
    # Shared functionality for multiple queries which update instance abilities
    # on users, verticals, roles and policies
    module UpdatesAbilities
      extend Memoist
      delegate :instance_abilities, to: :object_for_update

      def object_for_update
        object = find_by(find_params)
        authorized_user.current_ability.subscribe(:after_authorize!) { after_authorize }
        object
      end

      private

      def object_type
        object_for_update.class.name.downcase
      end

      def new_policy_abilities
        return unless params[:policy_id]

        policy = Abilities::Policy.where(tiny_id: params[:policy_id]).first
        raise "Invalid policy for type #{object_type}" unless object_type == policy.type

        abilities = policy.merge_attributes(object_for_update)
        abilities.map(&:attributes)
      end

      def new_instance_abilities
        return unless params[:instance_abilities]

        params[:instance_abilities].map(&:to_unsafe_hash)
      end

      def new_instance_ability
        return unless params[:instance_ability]

        Array.wrap(params[:instance_ability].to_unsafe_hash)
      end

      def new_abilities
        new_policy_abilities || new_instance_ability || new_instance_abilities
      end

      def after_authorize
        apply_abilities(new_abilities)
      end

      def apply_abilities(abilities)
        instance_abilities.clear if replace_abilities
        abilities.map { |ability_params| instance_abilities.update_ability(**ability_params) }
      end

      def replace_abilities
        defined?(params) && params[:replace]
      end

      memoize :object_for_update
    end
  end
end
