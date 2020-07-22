# frozen_string_literal: true

class User
  include Mongoid::Document
  include Mongoidable

  belongs_to :parent1, class_name: "Parent1", required: false
  belongs_to :parent2, class_name: "Parent2", required: false
  embeds_many :embedded_parents, class_name: "Parent1"
  inherits_abilities_from(:parent1)
  inherits_abilities_from(:parent2)

  abilities.define do
    can :do_user_class_stuff, User
    cannot :do_other_user_class_stuff, User
  end
end