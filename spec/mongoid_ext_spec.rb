# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"
RSpec.describe "mongoid_ext" do
  describe "inherits_abilities_from" do
    it "only supports singular relations" do
      expect { User.inherits_abilities_from(:embedded_parents) }.to raise_error(ArgumentError)
    end

    it "defines inherits_abilities_from on documet models" do
      expect(User).to respond_to(:inherits_abilities_from)
    end

    it "collects inherited ability tree" do
      expect(User.inherits_from[0][:name]).to eq :parent1
      expect(User.inherits_from[1][:name]).to eq :parent2
    end

    it "validates when klass is a string, it constantizes to a document" do
      expect { User.inherits_abilities_from(String) }.to raise_error(ArgumentError)
    end

    it "validates when klass is a symbol, it constantizes to a document" do
      expect { User.inherits_abilities_from(:string) }.to raise_error(ArgumentError)
    end

    it "passes validation when klass is a Mongoid::Document" do
      expect { User.inherits_abilities_from(:parent1) }.not_to raise_error(ArgumentError)
    end

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
  end

  describe "current_abilities" do
    it "traverses class and instance abilities" do
      parent_1 = Parent1.new
      parent_1.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :do_parent1_instance_things, subject: User)
      parent_2 = Parent2.new
      parent_2.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :do_parent2_instance_things, subject: User)
      user = User.new(
          parent1: parent_1,
          parent2: parent_2
        )
      user.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :do_user_instance_things, subject: User)

      expect(user.current_ability.permissions).to eq({
                                                         can:    {
                                                             do_parent1_class_stuff:     { "User" => [] },
                                                             do_parent1_instance_things: { "User" => [] },
                                                             do_parent2_class_stuff:     { "User" => [] },
                                                             do_parent2_instance_things: { "User" => [] },
                                                             do_user_class_stuff:        { "User" => [] },
                                                             do_user_instance_things:    { "User" => [] }
                                                         },
                                                         cannot: {
                                                             do_parent2_class_stuff:    { "User" => [] },
                                                             do_parent1_class_stuff:    { "User" => [] },
                                                             do_other_user_class_stuff: { "User" => [] }
                                                         }
                                                     })
    end

    it "allows blocks in ability definitions" do
      User.define_abilities do |abilities|
        abilities.can :do_stuff_to_other_user, User do |user|
          user.id == "1"
        end
      end
      current_user = User.new
      current_user.current_ability
      other_user = User.new(id: "1")
      expect(current_user.current_ability).to be_able_to(:do_stuff_to_other_user, other_user)

      other_user = User.new(id: "2")
      expect(current_user.current_ability).not_to be_able_to(:do_stuff_to_other_user, other_user)
    end
  end
end
