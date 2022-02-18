# frozen_string_literal: true

module Mongoidable
  class ProviderListener < Mongoidable::BaseListener
    attr_reader :cede_method_name,
                :recede_method_name
    def initialize(providee_relation)
      super
      @cede_method_name = "cede_#{providee_class_name.downcase}_abilities".to_sym
      @recede_method_name = "recede_#{providee_class_name.downcase}_abilities".to_sym
    end


    def call
      if [
        Mongoid::Association::Referenced::HasOne,
        Mongoid::Association::Embedded::EmbedsOne,
        Mongoid::Association::Referenced::BelongsTo
      ].any? { |relation_type| providee_relation.is_a? relation_type }
        provider_class.before_save do |document|
          # if changed.include?(inverse_relation.foreign_key)
          #   providee_collection = document.send(ability_providee_name)
          #   providee_collection.clear
          #   document.send(inverse_relation.name).send(ability_provider_name).each do |provided_ability|
          #     providee_collection.update_ability(**provided_ability.to_args)
          #   end
          # end
        end
        provider_class.after_initialize :gather_initial_values
        provider_class.after_find :gather_initial_values
        provider_class.after_save :gather_initial_values

        provider_class.before_create do |document|
          self.to_s
        end
        # provider_class.before_upsert do |document|
        #   self.to_s
        # end
        # provider_class.before_destroy do |document|
        #   self.to_s
        # end
      else
        self.to_s
        # define_provider_collection_callbacks
      end


      Mongoidable::Ability.embedded_in(provider_ability_collection_name)

      provider_class.embeds_many provider_ability_collection_name,
                                 class_name:   Mongoidable::ProvidedAbility,
                                 after_add:    cede_method_name,
                                 after_remove: recede_method_name

      define_dynamic_methods

      # TODO update providee abilities after provider change
      #   providee.provider (from nil to value, from value to value, from value to nil, providee.provider.destroy, providee.provider << new_value)
      #
      # TODO update providee abilities after providee change
      #   provider.providee (from nil to value, from value to value, from value to nil, provider.providee.destroy, provider.providee << new_value)
    end



    def define_dynamic_methods
      this = self
      cede_method = self.class.instance_method(:cede_ability)
      recede_method = self.class.instance_method(:recede_ability)
      gather_method = self.class.instance_method(:gather_initial_values)
      provider_class.attr_accessor providee_relation_was
      provider_class.define_method(:gather_initial_values) { gather_method.bind_call(this, self)}
      provider_class.define_method(cede_method_name) {|ability| cede_method.bind_call(this, self, ability)}
      provider_class.define_method(recede_method_name) {|ability| recede_method.bind_call(this, self, ability)}
    end

    def gather_initial_values(provider)
      # stores_foreign_key?
      # respond_to? :criteria

      # Is a many or one relation
      if providee_relation.respond_to? :criteria
        #  many
        provider.send "#{providee_relation_was}=", provider.send(providee_relation_name)&.pluck(:_id)
      else
        # one
        provider.send "#{providee_relation_was}=", provider.send(providee_relation_name)&.id
      end
    end

    def cede_ability(provider, ability)
      apply_to_all_providees(provider, ability.to_args)
    end

    def recede_ability(provider, ability)
      apply_to_all_providees(provider, ability.to_inverse_args)
    end

    # TODO: cede and recede may have perf implications and need a mass update instead of each
    def apply_to_all_providees(provider, args)
      Array.wrap(provider.send(providee_relation_name)).each { |providee| apply_to_providees(providee, args) }
    end

    def apply_to_providees(providees, args)
      providees.each { |providee| apply_to_providees(providee, args) }
    end

    def apply_to_providees(providee, args)
      ability_collection = providee.send(providee_ability_collection_name)
      ability_collection.update_ability(**args)
      providee.save
    end
  end
end