# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::Ability do
  it "accepts a class as the subject" do
    ability = Mongoidable::Ability.new(base_behavior: true, action: :do_something, subject: Mongoid::Document)
    expect(ability).to be_valid
    expect(ability.subject).to eq Mongoid::Document
  end

  it "accepts an attribute validation" do
    main_instance = User.new(id: 1)
    main_instance.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :do_something, subject: User, extra: [{ id: 2 }])
    expect(main_instance).to be_valid
    main_instance.save
    other_instance = User.new(id: 2)
    expect(other_instance).to be_valid
    other_instance.save

    expect(main_instance.current_ability.can?(:do_something, other_instance)).to be_truthy
    expect(main_instance.current_ability.can?(:do_something, main_instance)).to  be_falsey
  end
end
