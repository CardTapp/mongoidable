# frozen_string_literal: true

class Modules
  include Mongoid::Document
  include Mongoidable::Document
  include IncludedModule

  define_abilities do |abilities, _model|
    abilities.can :do_own_stuff, User
    abilities.cannot :do_other_own_stuff, User
  end
end
