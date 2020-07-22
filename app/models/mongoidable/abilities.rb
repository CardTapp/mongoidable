module Mongoidable
  class Abilities
    include Mongoidable.context_module if Mongoidable.context_module
    include ::CanCan::Ability
    def initialize
      define_singleton_method(:eval_abilities, -> {})
    end

    def define(&block)
      define_singleton_method(:eval_abilities, &block)
    end
  end
end
