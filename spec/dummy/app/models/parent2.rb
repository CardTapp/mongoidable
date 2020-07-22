# frozen_string_literal: true

class Parent2
  include Mongoid::Document
  include Mongoidable

  abilities.define do
    can :do_parent2_class_stuff, User
    cannot :do_parent1_class_stuff, User
  end
end