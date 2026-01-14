# frozen_string_literal: true

# The class that holds all abilities on classes, instances and adhoc
module Mongoidable
  class CaslHash < Hash
    def initialize(rule)
      self.action = rule
      self.subject = rule
      self.fields = rule
      self.conditions = rule
      self.inverted = rule
      self.block = rule
      self.source = rule
      self[:description] = rule.actions.map do |action|
        I18n.t("mongoidable.ability.description.#{action}", subject: self[:subject])
      end.join("/")
      self[:type] = rule.rule_type
      super
    end

    private

    def action=(rule)
      self[:action] = rule.actions
    end

    def source=(rule)
      source = rule.rule_source
      source = source.deep_symbolize_keys if source.respond_to?(:deep_symbolize_keys)

      self[:source] = source.presence
    end

    def fields=(rule)
      return if rule.attributes.blank?

      self[:fields] = rule.attributes.presence
    end

    def subject=(rule)
      self[:subject] = rule.subjects.map { |s| s.is_a?(Symbol) ? s : s.name }
    end

    def conditions=(rule)
      return if rule.conditions.blank?

      self[:conditions] = rule.conditions.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
    end

    def inverted=(rule)
      self[:inverted] = true unless rule.base_behavior
    end

    def block=(rule)
      variable = rule.instance_variable_get(:@block)
      self[:has_block] = false
      if variable
        self[:has_block] = true
        self[:block_ruby] = variable.source.strip if Mongoidable.configuration.serialize_ruby
        self[:block_js] = Ruby2JS.convert(variable.source.strip).to_s if Mongoidable.configuration.serialize_js
      end
    rescue Ruby2JS::Error
      self[:block_js] = "Unprocessable Block"
    end
  end
end
