# frozen_string_literal: true

module Mongoidable
  class ProvideeListener < Mongoidable::BaseListener
    attr_reader :apply_provider_method_name
    def initialize(providee_relation)
      super(providee_relation)
      @apply_provider_method_name = "apply_#{providee_class_name}_abilities".to_sym
    end

    def call
        providee_class.after_find do |document|
          self.to_s
        end
        providee_class.after_initialize do |document|
          self.to_s
        end
        providee_class.after_upsert do |document|
          self.to_s
        end
        providee_class.after_save do |document|
          self.to_s
        end
        providee_class.before_save do |document|
          self.to_s

        end
        providee_class.after_initialize do |document|
          self.to_s
        end
        providee_class.after_find do |document|
          self.to_s
        end
        providee_class.before_update do |document|
          self.to_s
        end
        providee_class.before_create do |document|
          self.to_s
        end
        providee_class.before_upsert do |document|
          self.to_s
        end
        providee_class.before_destroy do |document|
          self.to_s
        end

      providee_class.provided_ability_relations << providee_ability_collection_name

      Mongoidable::Ability.embedded_in(providee_ability_collection_name)
      providee_class.embeds_many providee_ability_collection_name,
                                 class_name: Mongoidable.configuration.ability_class do
        def update_ability(**attributes)
          Mongoidable::AbilityUpdater.new(parent_document, parent_document.send(association.name), attributes).call
          # TODO: parent_document.renew_abilities(types: :provider)
        end
      end

      providee_class.after_save apply_provider_method_name

      define_dynamic_methods
    end

    def define_dynamic_methods
      this = self
      apply_provider_method = self.class.instance_method(:apply_provider_abilities)
      providee_class.define_method(apply_provider_method_name) { apply_provider_method.bind_call(this, self)}
    end

    def apply_provider_abilities(providee)
      providee_abilities = providee.send(providee_ability_collection_name)
      Array.wrap(providee.send(provider_relation_name)).each do |provider|
        provider.send(provider_ability_collection_name).each do |ability|
          providee_abilities.update_ability(**ability.to_args)
        end
      end
    end
  end
end
