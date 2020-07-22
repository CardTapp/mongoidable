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

    it "passes validate whe klass is a Mongoid::Document" do
      expect { User.inherits_abilities_from(:parent1) }.not_to raise_error(ArgumentError)
    end

    it "classes properly inherit relations in derived classes" do
      inheritance = Inheritance.inherits_from.map { |relation| relation.name }
      expect(inheritance).to eq %i[parent1 parent2 parent3]
    end

    it "classes properly inherit abilities in derived classes" do
      expect(Inheritance.abilities.permissions).to eq({ can: { do_inherited_class_stuff: { "User"=>[] }, do_user_class_stuff: { "User"=>[] } }, cannot: { do_other_inherited_class_stuff: { "User"=>[] }, do_other_user_class_stuff: { "User"=>[] } } })
    end

    it "instances properly inherit abilities in derived classes" do
      expect(Inheritance.new.current_ability.permissions).to eq({ can: { do_inherited_class_stuff: { "User"=>[] }, do_user_class_stuff: { "User"=>[] } }, cannot: { do_other_inherited_class_stuff: { "User"=>[] }, do_other_user_class_stuff: { "User"=>[] } } })
    end
  end

  describe "add_own_ability" do
    let(:user) { User.new }
    let(:ability) { Mongoidable::Ability.new(base_behavior: true, action: :do_stuff, subject: "on_thing") }

    it "adds an ability to the owner using an ability parameter" do
      user.add_instance_ability(ability)
      expect(user.instance_abilities.where(action: :do_stuff).first).to be
    end

    it "adds an ability to the owner using parameter values" do
      user.add_instance_ability(true, :do_stuff, "on_thing")
      expect(user.instance_abilities.where(action: :do_stuff).first).to be
    end
  end

  describe "remove_own_ability" do
    let(:user) { User.new }
    let(:ability) { Mongoidable::Ability.new(base_behavior: true, action: :do_stuff, subject: "on_thing") }
    it "removes an ability from the owner using parameter values" do
      user.add_instance_ability(ability)
      user.save
      expect(user.instance_abilities.where(action: :do_stuff).first).to be

      user.remove_instance_ability(true, :do_stuff, "on_thing")
      expect(user.instance_abilities.where(action: :do_stuff).first).not_to be
    end

    it "removes an ability from the owner using an ability parameter" do
      user.add_instance_ability(ability)
      user.save
      expect(user.instance_abilities.where(action: :do_stuff).first).to be

      user.remove_instance_ability(ability)
      expect(user.instance_abilities.where(action: :do_stuff).first).not_to be
    end
  end

  describe "current_abilities" do
    it "traverses class and instance abilities" do
      parent_1 = Parent1.new(instance_abilities: [{ base_behavior: true, action: :do_parent1_instance_things, subject: "on_something" }])
      parent_2 = Parent2.new(instance_abilities: [{ base_behavior: true, action: :do_parent2_instance_things, subject: "on_something" }])
      user = User.new(
          instance_abilities: [{ base_behavior: true, action: :do_user_instance_things, subject: "on_another_thing" }],
          parent1:            parent_1,
          parent2:            parent_2
        )

      expect(user.current_ability.permissions).to eq({
                                                         can:    {
                                                             do_parent1_class_stuff:     { "User"=>[] },
                                                             do_parent1_instance_things: { "on_something"=>[] },
                                                             do_parent2_class_stuff:     { "User"=>[] },
                                                             do_parent2_instance_things: { "on_something"=>[] },
                                                             do_user_class_stuff:        { "User"=>[] },
                                                             do_user_instance_things:    { "on_another_thing"=>[] }
                                                         },
                                                         cannot: {
                                                             do_parent2_class_stuff:    { "User"=>[] },
                                                             do_parent1_class_stuff:    { "User"=>[] },
                                                             do_other_user_class_stuff: { "User"=>[] }
                                                         }
                                                     })
    end

    it "allows blocks in ability definitions" do
      User.abilities.define do
        can :do_stuff_to_other_user, User do |user|
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

    it "allows hashes in ability definitions" do
      current_user = User.new
      other_user = User.new(id: "1")
      allow(User.abilities).to receive(:current_user).and_return(current_user)
      User.abilities.define do
        can :do_stuff_to_other_user, id: current_user.id
      end
      expect(current_user.current_ability).to be_able_to(:do_stuff_to_other_user, other_user)

      other_user = User.new(id: "2")
      expect(current_user.current_ability).not_to be_able_to(:do_stuff_to_other_user, other_user)
    end
  end
end