# frozen_string_literal: true

module Mongoidable
  # A mongoid document used to store adhoc abilities.
  class Ability
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
    after_destroy :touch_parent
    after_save :touch_parent

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

      hash_attributes = extra.first
      hash_attributes.each do |key, path|
        next unless path.to_s.include?("merge|")

        attribute_path = path.gsub("merge|", "")
        hash_attributes[key] = data.with_indifferent_access.dig(*attribute_path.split("."))
      end
      @merged = true
    end

    private

    def touch_parent
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
      true
    end

    class << self
      extend Memoist

      def from_value(value)
        all.detect { |klass| klass.ability.to_s == value.to_s }
      end

      def all
        return @all if @all.present?

        Dir[Rails.root.join(config.load_path)].sort.each { |file| require file }

        namespace = config.ability_class.deconstantize.constantize

        @all = load_namespace(namespace).flatten
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

      memoize :all
    end
  end
end

::Ability = Mongoidable::Ability