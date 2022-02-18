# frozen_string_literal: true

module Mongoidable
  module Document
    extend Forwardable
    extend ActiveSupport::Concern

    include Mongoidable::ClassAbilities
    include Mongoidable::InstanceAbilities
    include Mongoidable::CurrentAbility
    include Mongoidable::AbilityProvider

    included do
      extend Mongoidable.configuration.context_module.constantize if Mongoidable.configuration.context_module
      include Mongoidable::DocumentExtensions

      after_initialize do
        renew_abilities(types: :all)
      end
    end

    class_methods do
      extend Memoist
      def default_ability
        Mongoidable.configuration.ability_class.constantize
      end
      memoize :default_ability
    end
  end
end