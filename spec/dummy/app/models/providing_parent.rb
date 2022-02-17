# frozen_string_literal: true

class ProvidingParent
  include Mongoid::Document
  include Mongoidable::Document

  has_one :providee, class_name: "User", inverse_of: :provider
  # has_many :providees, inverse_of: :provider_two

  provides_abilities_to :providee
  # provides_abilities_to :providees
end