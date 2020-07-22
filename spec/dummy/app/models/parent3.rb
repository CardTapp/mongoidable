# frozen_string_literal: true

class Parent3
  include Mongoid::Document
  include Mongoidable

  abilities.define do
    can :do_parent3_class_stuff, User
    cannot :do_parent2_class_stuff, User
  end
end