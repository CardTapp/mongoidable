# frozen_string_literal: true

# The class that holds all abilities on classes, instances and adhoc
module Mongoidable
  class Abilities
    include ::CanCan::Ability

    def to_casl_list
      rules.map { |rule| Mongoidable::CaslHash.new(rule) }
    end
  end
end
