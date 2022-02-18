# frozen_string_literal: true

module Mongoidable
  class ProvideeListener < Mongoidable::BaseListener
    attr_reader :apply_provider_method_name

    def initialize(providee_relation)
      super(providee_relation)
      @apply_provider_method_name = "apply_#{providee_class_name}_abilities".to_sym
    end

    def call
      providee_class.provided_ability_relations << providee_ability_collection_name

      bind_events
      define_relationship
      define_dynamic_methods
    end

    def bind_events
      providee_class.after_save apply_provider_method_name
    end

    def define_dynamic_methods
      this = self
      providee_class.define_method(apply_provider_method_name) { APPLY_PROVIDER_METHOD.bind_call(this, self) }
    end

    def define_relationship
      Mongoidable::Ability.embedded_in(providee_ability_collection_name)
      providee_class.embeds_many providee_ability_collection_name,
                                 class_name: Mongoidable.configuration.ability_class do
        def update_ability(**attributes)
          Mongoidable::AbilityUpdater.new(parent_document, parent_document.send(association.name), attributes).call
        end
      end
    end

    def apply_provider_abilities(providee)
      providee_abilities = providee.send(providee_ability_collection_name)
      Array.wrap(providee.send(provider_relation_name)).each do |provider|
        provider.send(provider_ability_collection_name).each do |ability|
          providee_abilities.update_ability(**ability.to_args)
        end
      end
    end

    APPLY_PROVIDER_METHOD = instance_method(:apply_provider_abilities)
  end
end
