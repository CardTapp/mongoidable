# frozen_string_literal: true

class GrandParent2a
  include Mongoid::Document

  class_abilities.can "do_grand_parent2a_class_stuff", User
  class_abilities.cannot "do_grand_parent2a_class_stuff", User
end