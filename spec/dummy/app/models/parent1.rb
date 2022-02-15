# frozen_string_literal: true

class Parent1
  include Mongoid::Document
  include Mongoidable::Document

  has_many :users, inverse_of: :paren1
  define_abilities do |abilities, model|
    abilities.can :do_parent1_class_stuff, User
    abilities.cannot :do_parent2_class_stuff, User
    abilities.can :do_nested_stuff, User do |other_user|
      model.tap do |tapped|
        tapped.to_s
        other_user.to_s
        tapped.to_s
      end
      true
    end
  end
end
