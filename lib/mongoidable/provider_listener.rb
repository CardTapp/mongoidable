# frozen_string_literal: true

module Mongoidable
  class ProviderListener
    attr_reader :providee_relation,
                :provider_relation,
                :providee_class,
                :provider_class,
                :providee_class_name,
                :provider_class_name,
                :providee_relation_name,
                :provider_relation_name,
                :provider_ability_collection_name,
                :providee_ability_collection_name,
                :cede_method_name,
                :recede_method_name
    def initialize(providee_relation)
      @providee_relation = providee_relation
      @providee_class = providee_relation.klass
      @providee_class_name = providee_class.name
      @provider_class = providee_relation.inverse_klass
      @provider_class_name = provider_class.name
      @providee_relation_name = providee_relation.name
      @provider_relation_name = providee_relation.inverse
      @provider_ability_collection_name = "#{providee_class_name.downcase}_abilities".to_sym
      @providee_ability_collection_name = "#{provider_class_name.downcase}_#{providee_class_name.downcase}_abilities".to_sym
      @provider_relation = providee_class.relations[provider_relation_name]
      @cede_method_name = "cede_#{providee_class_name}_abilities".to_sym
      @recede_method_name = "recede_#{providee_class_name}_abilities".to_sym
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
        # provider_class.before_update do |document|
        #   self.to_s
        # end
        # provider_class.before_create do |document|
        #   self.to_s
        # end
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
      provider_class.define_method(cede_method_name) {|ability| cede_method.bind_call(this, self, ability)}
      provider_class.define_method(recede_method_name) {|ability| recede_method.bind_call(this, self, ability)}
    end

    def cede_ability(provider, ability)
      apply_all_ability_changes(provider, ability.to_args)
    end

    def recede_ability(provider, ability)
      apply_all_ability_changes(provider, ability.to_inverse_args)
    end

    # TODO: cede and recede may have perf implications and need a mass update instead of each
    def apply_all_ability_changes(provider, args)
      Array.wrap(provider.send(providee_relation_name)).each do |providee|
        ability_collection = providee.send(providee_ability_collection_name)
        ability_collection.update_ability(**args)
        providee.save
      end
    end
  end
end