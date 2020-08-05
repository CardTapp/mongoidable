# frozen_string_literal: true

module Mongoidable
  module Document
    extend ActiveSupport::Concern

    included do
      extend Mongoidable.configuration.context_module if Mongoidable.configuration.context_module
      include Mongoidable::ClassAbilities
      include Mongoidable::CurrentAbility
      include Mongoidable::DocumentExtensions
      include Mongoidable::InstanceAbilities
    end
  end
end