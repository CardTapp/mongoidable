# frozen_string_literal: true

class Parent1
  include Mongoid::Document
  include Mongoidable::Document

  define_abilities do |abilities, _model|
    abilities.can :do_parent1_class_stuff, User
    abilities.cannot :do_parent2_class_stuff, User
  end
end
