# frozen_string_literal: true

module Mongoidable
  module Document
    extend Forwardable
    extend ActiveSupport::Concern

    include Mongoidable::ClassAbilities
    include Mongoidable::InstanceAbilities
    include Mongoidable::CurrentAbility
    include Mongoidable::RelationsDirtyTracking

    included do
      extend Mongoidable.configuration.context_module.constantize if Mongoidable.configuration.context_module
      include Mongoidable::DocumentExtensions

      after_initialize do
        @ancestral_abilities = nil
        @own_abilities = nil
      end
    end

    class_methods do
      def default_ability
        Mongoidable.configuration.ability_class.constantize
      end
    end
  end
end