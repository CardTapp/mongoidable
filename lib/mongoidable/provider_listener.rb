# frozen_string_literal: true

module Mongoidable
  class ProviderListener < Mongoidable::BaseListener
    attr_reader :cede_method_name,
                :recede_method_name,
                :destroy_method_name

    def initialize(providee_relation)
      super
      @cede_method_name = "cede_#{providee_class_name.downcase}_abilities".to_sym
      @recede_method_name = "recede_#{providee_class_name.downcase}_abilities".to_sym
      @destroy_method_name = "destroy_#{providee_class_name.downcase}_abilities".to_sym
    end

    def call
      bind_events
      define_relationship
      define_dynamic_methods
    end

    def bind_events
      provider_class.after_initialize :gather_initial_values
      provider_class.after_find :gather_initial_values
      provider_class.after_save :update_providees
      provider_class.after_save :gather_initial_values
      provider_class.after_destroy destroy_method_name
    end

    def define_relationship
      Mongoidable::Ability.embedded_in(provider_ability_collection_name)

      provider_class.embeds_many provider_ability_collection_name,
                                 class_name:   Mongoidable::ProvidedAbility,
                                 after_add:    cede_method_name,
                                 after_remove: recede_method_name
    end

    def define_dynamic_methods
      this = self
      provider_class.attr_accessor providee_relation_was
      provider_class.define_method(:gather_initial_values) { GATHER_METHOD.bind_call(this, self) }
      provider_class.define_method(:update_providees) { UPDATE_PROVIDEES_METHOD.bind_call(this, self) }
      provider_class.define_method(cede_method_name) { |ability| CEDE_METHOD.bind_call(this, self, ability) }
      provider_class.define_method(recede_method_name) { |ability| RECEDE_METHOD.bind_call(this, self, ability) }
      provider_class.define_method(destroy_method_name) { DESTROY_METHOD.bind_call(this, self) }
    end

    def update_providees(provider)
      current_ids    = Array.wrap(related_ids_from_model(provider))
      old_ids        = Array.wrap(provider.send(providee_relation_was))
      added_ids      = current_ids - old_ids
      removed_ids    = old_ids - current_ids

      added, removed = if providee_relation.respond_to? :criteria
                         #  many
                         [
                           provider.send(providee_relation_name).where(providee_relation.primary_key.to_sym.in => added_ids),
                           providee_class.where(providee_relation.primary_key.to_sym.in => removed_ids)
                         ]
                       else
                         # one
                         [
                           Array.wrap(provider.send(providee_relation_name)),
                           providee_class.where(providee_relation.primary_key.to_sym.in => removed_ids)
                         ]
                       end

      provider.send(provider_ability_collection_name).each do |ability|
        apply_to_providees(added, ability.to_args)
        apply_to_providees(removed, ability.to_inverse_args)
      end
    end

    def gather_initial_values(provider)
      provider.send "#{providee_relation_was}=", related_ids_from_model(provider)
    end

    def related_ids_from_model(model)
      # Many or one relation, stored key or not
      if providee_relation.stores_foreign_key?
        model.send(providee_relation.foreign_key)
      elsif providee_relation.respond_to? :criteria
        model.send(providee_relation_name)&.pluck(:_id)
        #  many
      else
        # one
        model.send(providee_relation_name)&.id
      end
    end

    def cede_ability(provider, ability)
      providees = Array.wrap(provider.send(providee_relation_name))
      apply_to_providees(providees, ability.to_args)
    end

    def recede_ability(provider, ability)
      providees = Array.wrap(provider.send(providee_relation_name))
      apply_to_providees(providees, ability.to_inverse_args)
    end

    def destroy_abilities(provider)
      providees = Array.wrap(provider.send(providee_relation_name))
      provider.send(provider_ability_collection_name).each do |ability|
        apply_to_providees(providees, ability.to_inverse_args)
      end
    end

    # TODO: cede and recede may have perf implications and need a mass update instead of each
    def apply_to_providees(providees, args)
      providees.each { |providee| apply_to_providee(providee, args) }
    end

    def apply_to_providee(providee, args)
      ability_collection = providee.send(providee_ability_collection_name)
      ability_collection.update_ability(**args)
      providee.save
    end

    CEDE_METHOD = instance_method(:cede_ability)
    DESTROY_METHOD = instance_method(:destroy_abilities)
    GATHER_METHOD = instance_method(:gather_initial_values)
    RECEDE_METHOD = instance_method(:recede_ability)
    UPDATE_PROVIDEES_METHOD = instance_method(:update_providees)
  end
end