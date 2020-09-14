# frozen_string_literal: true

module Mongoidable
  # Helper for formating a casl list
  module CaslList
    def to_casl_list
      rules.map { |rule| Mongoidable::CaslHash.new(rule) }
    end
  end
end
