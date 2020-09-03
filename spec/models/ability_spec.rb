# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::Ability do
  it "accepts a class as the subject" do
    ability = Mongoidable::Ability.new(base_behavior: true, action: :do_something, subject: Mongoid::Document)
    expect(ability).to be_valid
    expect(ability.subject).to eq Mongoid::Document
  end

  it "accepts a symbol as the subject" do
    ability = Mongoidable::Ability.new(base_behavior: true, action: :do_something, subject: :asdf)
    expect(ability).to be_valid
    expect(ability.subject).to eq :asdf
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

  it "adds the instance ability source to the rule" do
    main_instance = User.new(id: 1)
    main_instance.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :do_something, subject: User, extra: [{ id: 2 }])
    list = main_instance.current_ability.to_casl_list
    expect(list[2][:source]).to eq({ id: 1, model: "User" })
  end

  it "adds the ability action description to the rule" do
    main_instance = User.new(id: 1)
    main_instance.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :do_something, subject: User, extra: [{ id: 2 }])
    allow(I18n).to receive(:t).
        with("mongoidable.ability.description.do_user_class_stuff", { subject: ["User"] }).
        and_return("This is my do_user_class_stuff description")
    allow(I18n).to receive(:t).
        with("mongoidable.ability.description.do_other_user_class_stuff", { subject: ["User"] }).
        and_return("This is my do_other_user_class_stuff description")
    allow(I18n).to receive(:t).
        with("mongoidable.ability.description.do_something", { subject: ["User"] }).
        and_return("This is my do_something description")
    list = main_instance.current_ability.to_casl_list
    expect(list[2][:description]).to eq "This is my do_something description"
  end
end
