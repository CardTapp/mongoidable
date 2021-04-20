# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::AbilityUpdater do
  let(:user) { User.new }
  class self::Model
    include Mongoid::Document
    include Mongoidable::Document
  end
  let(:model) { self.class::Model.create }

  it "creates an ability if necessary" do
    updater = Mongoidable::AbilityUpdater.new(model, { action: :action, subject: :subject, base_behavior: true })
    updater.call

    expect(model.current_ability).to be_can(:action, :subject)

    ability = model.instance_abilities.first
    expect(ability.action).to eq :action
    expect(ability.subject).to eq :subject
  end

  it "destroys an existing ability if necessary" do
    model.instance_abilities.create(action: :action, subject: :subject, base_behavior: true)

    expect(model.current_ability).to be_can(:action, :subject)

    updater = Mongoidable::AbilityUpdater.new(model, { action: :action, subject: :subject, base_behavior: false })
    updater.call

    expect(model.current_ability).not_to be_can(:action, :subject)
    expect(model.instance_abilities.first).not_to be
  end

  it "does nothing when adding same ability" do
    model.instance_abilities.create(action: :action, subject: :subject, base_behavior: true)

    expect(model.current_ability).to be_can(:action, :subject)

    updater = Mongoidable::AbilityUpdater.new(model, { action: :action, subject: :subject, base_behavior: true })
    updater.call

    expect(model.current_ability).to be_can(:action, :subject)
    expect(model.instance_abilities.first).to be
  end

  it "does nothing when adding same ability with extra args" do
    model.instance_abilities.create(
      action: :action,
      subject: User,
      base_behavior: true,
      extra:         [{ id: user.id }])

    expect(model.current_ability).to be_can(:action, user)

    updater = Mongoidable::AbilityUpdater.new(model, {
      action: :action,
      subject: User,
      base_behavior: true,
      extra: [{ id: user.id }]})
    updater.call

    expect(model.current_ability).to be_can(:action, user)
    expect(model.instance_abilities.first).to be
  end

  it "does nothing when adding same ability with extra merge args" do
    model.instance_abilities.create(
      action: :action,
      subject: User,
      base_behavior: true,
      extra:         [{ id: "merge|user.id" }])

    updater = Mongoidable::AbilityUpdater.new(model, {
      action: :action,
      subject: User,
      base_behavior: true,
      extra: [{ id: "merge|user.id" }]})
    updater.call

    expect(model.instance_abilities.first).to be
  end
end