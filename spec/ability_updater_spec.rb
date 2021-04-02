# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::AbilityUpdater do
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

  it "does nothing" do
    model.instance_abilities.create(action: :action, subject: :subject, base_behavior: true)

    expect(model.current_ability).to be_can(:action, :subject)

    updater = Mongoidable::AbilityUpdater.new(model, { action: :action, subject: :subject, base_behavior: true })
    updater.call

    expect(model.current_ability).to be_can(:action, :subject)
    expect(model.instance_abilities.first).to be
  end
end