# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"
RSpec.describe "test_mode" do
  it "can? raises if helpers are not configured" do
    expect { User.new.current_ability.can?(:do_user_class_stuff, User) }.to raise_error
  end

  it "cannot? raises if helpers are not configured" do
    expect { User.new.current_ability.cannot?(:do_user_class_stuff, User) }.to raise_error
  end

  it "passes ability checks to real ability if with_abilities", :with_abilities do
    expect(User.new.current_ability.can?(:do_user_class_stuff, User)).to eq true
  end

  it "defaults default_can_ability_with to true when called", default_can_ability_with: true do
    expect(User.new.current_ability.can?(:do_thing, User)).to eq true
  end

  it "defaults default_can_ability_with to false when called", default_can_ability_with: false do
    expect(User.new.current_ability.can?(:do_thing, User)).to eq false
  end

  it "defaults default_cannot_ability_with to true when called", default_cannot_ability_with: true do
    expect(User.new.current_ability.cannot?(:do_thing, User)).to eq true
  end

  it "defaults default_cannot_ability_with to false when called", default_cannot_ability_with: false do
    expect(User.new.current_ability.cannot?(:do_thing, User)).to eq false
  end
end