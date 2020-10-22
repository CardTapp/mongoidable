# frozen_string_literal: true

class Inheritance < User
  belongs_to :parent3, class_name: "Parent3", optional: true

  inherits_abilities_from(:parent3)

  define_abilities do |abilities, _model|
    abilities.can :do_inherited_class_stuff, User
    abilities.cannot :do_other_inherited_class_stuff, User
  end
end
