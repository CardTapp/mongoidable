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
      extend Mongoidable.configuration.context_module if Mongoidable.configuration.context_module
      include Mongoidable::DocumentExtensions

      after_initialize do
        @ancestral_abilities = nil
        @own_abilities = nil
      end
    end
  end
end