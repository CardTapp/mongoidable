# frozen_string_literal: true

module Mongoidable
  class AbilityUpdater
    attr_accessor :instance_abilities, :arguments, :parent_document

    def initialize(parent_document, arguments)
      @parent_document    = parent_document
      @instance_abilities = parent_document.instance_abilities
      @arguments          = if arguments.is_a?(ActionController::Parameters)
                              arguments.to_unsafe_hash
                            else
                              arguments
                            end.with_indifferent_access
    end

    def call
      return unless should_update?

      if ability_exists?
        destroy_ability
      else
        create_ability
      end
    end

    def destroy_ability
      database_ability.destroy
    end

    def create_ability
      method = parent_document.new_record? ? :build : :create
      instance_abilities.send(method, create_attributes, ability_type)
    end

    def database_ability
      instance_abilities.detect { |ability| ability == ability_representation }
    end

    def should_update?
      # If the ability change includes model attributes new up a model with those attributes to check
      can_args = if subject_as_class.is_a?(Symbol) || extra.blank?
                   [action, subject_as_class]
                 else
                   subject = subject_as_class.new
                   transform_values(subject, extra.first)
                   [action, subject]
                 end
      parent_document.current_ability.can?(*can_args) != base_behavior
    end

    def ability_exists?
      database_ability.present?
    end

    def ability_representation
      Mongoidable::Ability.new(base_behavior: base_behavior, action: action, subject: subject, extra: extra)
    end

    def create_attributes
      {
          action:        action,
          base_behavior: base_behavior,
          subject:       subject_as_class,
          extra:         extra
      }
    end

    def base_behavior
      ActiveModel::Type::Boolean.new.cast(arguments.fetch(:base_behavior) { arguments[:enabled] })
    end

    def extra
      arguments[:extra]
    end

    def action
      arguments[:action].to_sym
    end

    def subject
      arguments[:subject]
    end

    def subject_as_class
      subject.is_a?(Hash) ? Mongoidable::ClassType.demongoize(subject) : subject
    end

    def ability_type
      Mongoidable::Ability.from_value(action) || parent_document.class.default_ability
    end

    def transform_values(object, hash)
      hash.each do |key, value|
        key  = "_id" if key.to_s == "id"
        type = object.fields[key].type
        if type == Array
          many_to_many_relation = object.relations.detect do |_name, relation|
            relation.key == key && relation.is_a?(Mongoid::Association::Referenced::HasAndBelongsToMany)
          end
          value = Array.wrap(value)

          if many_to_many_relation
            relation_name = many_to_many_relation.first

            value.each do |assign_value|
              object.public_send(relation_name).build(id: assign_value)
            end
          else
            object.assign_attributes(key => value)
          end
        elsif type == Mongoid::Document
          transform_values(object[key], value)
        else
          object.assign_attributes(key => value)
        end
      end
    end
  end
end
