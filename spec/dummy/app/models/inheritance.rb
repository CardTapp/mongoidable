# frozen_string_literal: true

class Inheritance < User
  belongs_to :parent3, class_name: "Parent3", required: false

  inherits_abilities_from(:parent3)

  abilities.define do
    can :do_inherited_class_stuff, User
    cannot :do_other_inherited_class_stuff, User
  end
end