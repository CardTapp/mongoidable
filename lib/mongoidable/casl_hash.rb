# frozen_string_literal: true

# The class that holds all abilities on classes, instances and adhoc
module Mongoidable
  class CaslHash < Hash
    def initialize(rule)
      self.actions = rule
      self.subject = rule
      self.conditions = rule
      self.inverted = rule
      self.block = rule
    end

    private

    def actions=(rule)
      self[:actions] = rule.actions
    end

    def subject=(rule)
      self[:subject] = rule.subjects.map { |s| s.is_a?(Symbol) ? s : s.name }
    end

    def conditions=(rule)
      self[:conditions] = rule.conditions unless rule.conditions.blank?
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
