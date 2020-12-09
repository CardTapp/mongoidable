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

    embedded_in :instance_abilities, touch: true
    after_destroy :touch_parent
    after_save :touch_parent

    def description
      I18n.t("mongoidable.ability.description.#{action}", subject: self[:subject])
    end

    def inspect
      behavior = base_behavior ? "can" : "cannot"
      "#{behavior} #{action.inspect} for #{subject.inspect}"
    end

    private

    def valid_for_parent?
      true
    end

    def touch_parent
      _parent.touch
    end
  end
end