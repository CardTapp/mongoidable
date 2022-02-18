# frozen_string_literal: true

module Mongoidable
  class ProvideeListener < Mongoidable::BaseListener

    def initialize(providee_relation)
      super(providee_relation)
    end

    def call
      providee_class.provided_ability_relations << providee_ability_collection_name
      define_relationship
    end

    def define_relationship
      Mongoidable::Ability.embedded_in(providee_ability_collection_name)
      providee_class.embeds_many providee_ability_collection_name,
                                 class_name: Mongoidable.configuration.ability_class
    end
  end
end
