# frozen_string_literal: true

# The class that holds all abilities on classes, instances and adhoc
module Mongoidable
  class Abilities
    include Mongoidable.context_module if Mongoidable.context_module
    include ::CanCan::Ability
    def initialize
      define_singleton_method(:eval_abilities, -> {})
    end

    # Defines a method on the instance to ensure the block has proper binding context
    def define(&block)
      define_singleton_method(:eval_abilities, &block)
    end
  end
end
