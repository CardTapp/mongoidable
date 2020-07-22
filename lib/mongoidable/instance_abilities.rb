# frozen_string_literal: true

module Mongoidable
  # Defines methods necessary to add and remove instance abilities
  module InstanceAbilities
    # Add an ability to the current instance
    # Abilities may be passed in the following formats (Ability may be a derived type)
    #   add_instance_ability(Ability.new)
    #   add_instance_ability(base_behavior, action, subject, extra)
    #   add_instance_ability(base_behavior: value, action: value, subject: value, extra: value)
    def add_instance_ability(*args)
      ability = parse_ability_args(*args)
      instance_abilities << ability
    end

    # Remove an ability from the current instance
    # Abilities may be passed in the following formats (Ability may be a derived type)
    #   add_instance_ability(Ability.new)
    #   add_instance_ability(base_behavior, action, subject, extra)
    #   add_instance_ability(base_behavior: value, action: value, subject: value, extra: value)
    def remove_instance_ability(*args)
      ability = parse_ability_args(*args)
      found_ability = instance_abilities.where(base_behavior: ability.base_behavior, action: ability.action, subject: ability.subject).first
      instance_abilities.delete(found_ability) if found_ability.present?
    end

    private

    def parse_ability_args(*args)
      return args[0] if args.length == 1 && args[0].is_a?(Mongoidable::Ability)

      raise ArgumentError, "Invalid arguments" if args.length > 1 && args.length < 3

      Mongoidable::Ability.new(*args)
    end

    def own_abilities
      @own_abilities = Mongoidable::Abilities.new
      instance_abilities.each do |ability|
        if ability.base_behavior
          @own_abilities.can(*ability.to_a)
        else
          @own_abilities.cannot(*ability.to_a)
        end
      end
      @own_abilities
    end
  end
end