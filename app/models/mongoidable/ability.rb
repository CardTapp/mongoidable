# frozen_string_literal: true

module Mongoidable
  # A mongoid document used to store adhoc abilities.
  class Ability
    extend Memoist
    include ::Mongoid::Document

    attr_accessor :check_block

    # The action being defined (:something)
    field :action, type: Symbol
    # The class or instance the ability is defined for
    field :subject, type: Mongoidable::ClassType
    # Is this a grant or a revocation
    field :base_behavior, type: Boolean, default: true
    # Extra arguments as defined by cancancan.
    field :extra, type: Array

    validates :action, presence: true
    validate do |object|
      errors[:subject] << "cannot be blank" if object.subject.nil?
      errors[:parent] << "does not support model of type #{_parent.class.name}" unless valid_for_parent?
      errors[:parent] << "ability must be embedded in another model" if _parent.blank?
    end
    validates :base_behavior, presence: true

    embedded_in :instance_abilities
    after_destroy :after_action
    after_save :after_action

    class << self
      def attributes_and_conditions(extra)
        attributes_and_conditions_return = [[], []]

        Array.wrap(extra).each do |a_or_c|
          attributes_and_conditions_return[a_or_c.respond_to?(:each) ? 1 : 0] << a_or_c
        end

        attributes_and_conditions_return
      end
    end

    def extra_attributes
      Mongoidable::Ability.attributes_and_conditions(extra)[0]
    end

    def extra_conditions
      Mongoidable::Ability.attributes_and_conditions(extra)[1]
    end

    def description
      I18n.t("mongoidable.ability.description.#{action}", subject: self[:subject])
    end

    def inspect
      behavior = base_behavior ? "can" : "cannot"
      "#{behavior} #{attributes["action"]} for #{attributes["subject"]} where #{attributes["extra"]}"
    end

    def ==(other)
      other.action == action &&
        other.subject == subject &&
        other.extra == extra
    end

    def merge_requirements(data)
      return if @merged
      return if extra.blank?

      extra_conditions.each do |hash_attributes|
        hash_attributes.each do |key, path|
          next unless path.to_s.include?("merge|")

          attribute_path = path.gsub("merge|", "")
          hash_attributes[key] = data.with_indifferent_access.dig(*attribute_path.split("."))
        end
      end

      @merged = true
    end

    private

    def after_action
      _parent.renew_abilities(types: :instance)
      _parent.touch
    end

    def method_missing(name, *args, &block)
      # A super class knows about all fields defined in derived classes.
      # Mongoid Serializable attempts to serialize all known fields as they exist in the fields hash
      # This can fail if self is not of a type that contains that field.
      # If we know the field exists in some class, but we currently do not respond to it, return an empty string
      fields.key?(name.to_s) ? "" : super
    end

    def valid_for_parent?
      self.class.valid_for?(_parent.class)
    end

    class << self
      extend Memoist

      def valid_for?(_parent_klass)
        true
      end

      def from_value(action, subject, parent_class)
        (all - [self, Mongoidable.configuration.ability_class.constantize]).detect do |ability_klass|
          ability = ability_klass.new(action: action, subject: subject)
          ability.action == action && ability.subject == subject && ability_klass.valid_for?(parent_class)
        end
      end

      def all
        Dir[Rails.root.join(config.load_path)].sort.each { |file| require file }

        namespace = config.ability_class.deconstantize.constantize

        load_namespace(namespace).flatten
      end

      def ability
        :ability
      end

      def permitted_params
        [:action, :base_behavior, :enabled, { subject: %i[type value] }]
      end

      private

      def load_namespace(namespace)
        namespace.constants.filter_map do |const|
          const = namespace.const_get(const)
          if const.instance_of?(Module)
            load_namespace(const)
          elsif const.instance_of?(Class) && const <= Mongoidable::Ability
            const
          else
            next
          end
        end
      end

      def config
        Mongoidable.configuration
      end

      memoize :all, :valid_for?, :from_value
    end
  end
end

::Ability = Mongoidable::Ability