# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"
RSpec.describe "current_ability" do
  it "classes properly inherit relations in derived classes" do
    parent_1 = Parent1.new
    parent_2 = Parent2.new
    parent_3 = Parent3.new
    permissions = Inheritance.new(parent1: parent_1, parent2: parent_2, parent3: parent_3).current_ability.permissions
    expect(permissions).to eq({
                                  can:    {
                                      do_inherited_class_stuff: { "User" => [] },
                                      do_parent1_class_stuff:   { "User" => [] },
                                      do_parent2_class_stuff:   { "User" => [] },
                                      do_parent3_class_stuff:   { "User" => [] },
                                      do_user_class_stuff:      { "User" => [] }
                                  },
                                  cannot: {
                                      do_other_inherited_class_stuff: { "User" => [] },
                                      do_other_user_class_stuff:      { "User" => [] },
                                      do_parent1_class_stuff:         { "User" => [] },
                                      do_parent2_class_stuff:         { "User" => [] }
                                  }
                              })
  end

  it "classes properly inherit abilities in derived classes" do
    expect(Inheritance.new.current_ability.permissions).to eq(
        {
            can:
                    {
                        do_inherited_class_stuff: { "User" => [] },
                        do_user_class_stuff:      { "User" => [] }
                    },
            cannot:
                    {
                        do_other_inherited_class_stuff: { "User" => [] },
                        do_other_user_class_stuff:      { "User" => [] }
                    }
        }
      )
  end

  it "instances properly inherit abilities in derived classes" do
    expect(Inheritance.new.current_ability.permissions).to eq(
        {
            can:
                    {
                        do_inherited_class_stuff: { "User" => [] },
                        do_user_class_stuff:      { "User" => [] }
                    },
            cannot:
                    {
                        do_other_inherited_class_stuff: { "User" => [] },
                        do_other_user_class_stuff:      { "User" => [] }
                    }
        }
      )
  end

  it "traverses class and instance abilities" do
    parent_1 = Parent1.new(instance_abilities: [
                               { base_behavior: true, action: :do_parent1_instance_things, subject: :on_something }
                           ])
    parent_2 = Parent2.new(instance_abilities: [
                               { base_behavior: true, action: :do_parent2_instance_things, subject: :on_something }
                           ])
    user = User.new(
        instance_abilities: [{ base_behavior: true, action: :do_user_instance_things, subject: :on_another_thing }],
        parent1:            parent_1,
        parent2:            parent_2
      )

    expect(user.current_ability.permissions).to eq({
                                                       can:    {
                                                           do_parent1_class_stuff:     { "User" => [] },
                                                           do_parent1_instance_things: { "on_something" => [] },
                                                           do_parent2_class_stuff:     { "User" => [] },
                                                           do_parent2_instance_things: { "on_something" => [] },
                                                           do_user_class_stuff:        { "User" => [] },
                                                           do_user_instance_things:    { "on_another_thing" => [] }
                                                       },
                                                       cannot: {
                                                           do_parent2_class_stuff:    { "User" => [] },
                                                           do_parent1_class_stuff:    { "User" => [] },
                                                           do_other_user_class_stuff: { "User" => [] }
                                                       }
                                                   })
  end

  it "supports inheritance from pluralized relationships" do
    user = User.new
    one = Parent1.new
    user.embedded_parents << one
    two = Parent2.new
    user.embedded_parents << two

    one.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :one_thing, subject: User)
    two.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :two_thing, subject: User)

    User.inherits_abilities_from_many :embedded_parents, :id, :asc
    expect(user.current_ability.can?(:one_thing, User)).to eq true
    expect(user.current_ability.can?(:two_thing, User)).to eq true
  end

  it "applies sort order to embedded relations" do
    user = User.new
    one = Parent1.new(id: 1)
    user.embedded_parents << one
    two = Parent2.new(id: 2)
    user.embedded_parents << two

    one.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :override_thing, subject: User)
    two.instance_abilities << Mongoidable::Ability.new(base_behavior: false, action: :override_thing, subject: User)

    User.inherits_abilities_from_many :embedded_parents, :id
    expect(user.current_ability.cannot?(:override_thing, User)).to eq true
  end

  it "passes the relations parent model to define abilities" do
    user = User.new
    parent = Parent1.new(id: 1)
    user.embedded_parents << parent
    User.inherits_abilities_from_many :embedded_parents, :id, :asc

    expect(User.ability_definition).to receive(:call) do |_abilities, model|
      expect(model.parent_model).to eq nil
    end
    expect(Parent1.ability_definition).to receive(:call) do |_abilities, model|
      expect(model.parent_model).to eq user
    end

    user.current_ability
  end
end
