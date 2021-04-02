# frozen_string_literal: true

module Mongoidable
  module Scopes
      # Scopes used by Filterable Policy
      module Policy
        extend ActiveSupport::Concern

        included do
          scope :id, ->(id) { where(id: id) }
        end
      end
    end
  end

