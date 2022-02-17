# frozen_string_literal: true

module Mongoidable
  class BaseListener
    attr_reader :providee_relation,
                :provider_relation,
                :providee_class,
                :provider_class,
                :providee_class_name,
                :provider_class_name,
                :providee_relation_name,
                :provider_relation_name,
                :provider_ability_collection_name,
                :providee_ability_collection_name
    def initialize(providee_relation)
      @providee_relation = providee_relation
      @providee_class = providee_relation.klass
      @providee_class_name = providee_class.name
      @provider_class = providee_relation.inverse_klass
      @provider_class_name = provider_class.name
      @providee_relation_name = providee_relation.name
      @provider_relation_name = providee_relation.inverse
      @provider_ability_collection_name = "#{providee_class_name.downcase}_abilities".to_sym
      @provider_ability_collection_alias = "#{provider_ability_collection_name}_alias".to_sym
      @provider_ability_collection_was = "#{provider_ability_collection_name}_was".to_sym
      @providee_ability_collection_name = "#{provider_class_name.downcase}_#{providee_class_name.downcase}_abilities".to_sym
      @providee_ability_collection_alias = "#{providee_ability_collection_name}_alias".to_sym
      @providee_ability_collection_was = "#{providee_ability_collection_name}_was".to_sym
      @provider_relation = providee_class.relations[provider_relation_name]
    end
  end
end
