# frozen_string_literal: true

class ManyRelation
  include Mongoid::Document

  field :name, type: String

  has_and_belongs_to_many :users
end
