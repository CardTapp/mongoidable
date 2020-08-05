# frozen_string_literal: true

# The class that holds all abilities on classes, instances and adhoc
module Mongoidable
  class Abilities
    include ::CanCan::Ability
  end
end
