# frozen_string_literal: true

class Parent1
  include Mongoid::Document

  class_abilities.can "do_parent1_class_stuff", User
  class_abilities.cannot "do_parent2_class_stuff", User
end