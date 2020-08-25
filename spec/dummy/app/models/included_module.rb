# frozen_string_literal: true

module IncludedModule
  extend ActiveSupport::Concern

  included do
    define_abilities do |abilities, _user|
      # MassText
      abilities.can :do_included_stuff, User
    end
  end
end
