# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"
RSpec.describe "mongoid_ext", :with_abilities do
  describe "current_abilities" do
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

    it "allows blocks in ability definitions" do
      User.define_abilities do |abilities, _user|
        abilities.can :do_stuff_to_other_user, User do |other_user|
          other_user.id == "1"
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
