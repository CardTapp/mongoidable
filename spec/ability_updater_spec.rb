# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::AbilityUpdater do
  let(:user) { User.new }
  let(:model) { self.class::Model.create }

  module self
    class Model
    include Mongoid::Document
    include Mongoidable::Document
    end
  end

  it "creates an ability if necessary" do
    updater = Mongoidable::AbilityUpdater.new(model, { action: :action, subject: :subject, base_behavior: true })
    updater.call

    expect(model.current_ability).to be_can(:action, :subject)

    ability = model.instance_abilities.first
    expect(ability.action).to eq :action
    expect(ability.subject).to eq :subject
  end

  it "creates an ability by class if appropriate" do
    updater = Mongoidable::AbilityUpdater.new(user, { action: :specific_ability, subject: :specific_subject, base_behavior: true })
    updater.call

    expect(user.current_ability).to be_can(:specific_ability, :specific_subject)

    ability = user.instance_abilities.first
    expect(ability.action).to eq :specific_ability
    expect(ability.subject).to eq :specific_subject
    expect(ability).to be_a(Mongoidable::SpecificAbility)
  end

  it "calls the callbacks on a class if unset" do
    updater = Mongoidable::AbilityUpdater.new(user, { action: :specific_ability, subject: :specific_subject, base_behavior: true })
    updater.call

    updater = Mongoidable::AbilityUpdater.new(user, { action: :specific_ability, subject: :specific_subject, extra: [], base_behavior: false })
    expect { updater.call }.to raise_error "Testing that destroy is called"
  end

  it "creates an ability by class if appropriate if subject is hash" do
    updater = Mongoidable::AbilityUpdater.new(user,
                                              { action: :specific_ability,
                                                subject: { type: "symbol", value: "specific_subject" },
                                                base_behavior: true })
    updater.call

    expect(user.current_ability).to be_can(:specific_ability, :specific_subject)

    ability = user.instance_abilities.first
    expect(ability.action).to eq :specific_ability
    expect(ability.subject).to eq :specific_subject
    expect(ability).to be_a(Mongoidable::SpecificAbility)
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

  it "does nothing when adding same ability and attribute" do
    model.instance_abilities.create(action: :action, subject: :subject, base_behavior: true, extra: [:name])

    expect(model.current_ability).to be_can(:action, :subject, :name)

    updater = Mongoidable::AbilityUpdater.new(model, { action: :action, subject: :subject, base_behavior: true, extra: [:name] })
    updater.call

    expect(model.current_ability).to be_can(:action, :subject, :name)
    expect(model.instance_abilities.first).to be
  end

  it "does nothing when adding same ability with extra args" do
    model.instance_abilities.create(
      action: :action,
      subject: User,
      base_behavior: true,
      extra: [{ id: user.id }]
      )

    expect(model.current_ability).to be_can(:action, user)

    updater = Mongoidable::AbilityUpdater.new(model, {
                                                  action: :action,
        subject: User,
        base_behavior: true,
        extra: [{ id: user.id }]
                                              })
    updater.call

    expect(model.current_ability).to be_can(:action, user)
    expect(model.instance_abilities.first).to be
    expect(model.instance_abilities.count).to eq 1
  end

  it "does nothing when adding same ability with attribute extra args" do
    model.instance_abilities.create(
      action: :action,
      subject: User,
      base_behavior: true,
      extra: [:name, { id: user.id }]
      )

    expect(model.current_ability).to be_can(:action, user, :name)

    updater = Mongoidable::AbilityUpdater.new(model, {
                                                  action: :action,
        subject: User,
        base_behavior: true,
        extra: [:name, { id: user.id }]
                                              })
    updater.call

    expect(model.current_ability).to be_can(:action, user, :name)
    expect(model.instance_abilities.first).to be
    expect(model.instance_abilities.count).to eq 1
  end

  it "does nothing when adding same ability with extra merge args" do
    model.instance_abilities.create(
      action: :manage,
      subject: User,
      base_behavior: true,
      extra: [{ id: "merge|organization.user.id" }]
      )

    updater = Mongoidable::AbilityUpdater.new(model, {
                                                  action: :action,
        subject: User,
        base_behavior: true,
        extra: [{ id: "merge|organization.user.id" }]
                                              })
    updater.call

    expect(model.instance_abilities.first).to be
    expect(model.instance_abilities.count).to eq 1
  end

  it "does nothing when adding same ability with attribute and extra merge args" do
    model.instance_abilities.create(
      action: :manage,
      subject: User,
      base_behavior: true,
      extra: [:name, { id: "merge|organization.user.id" }]
      )

    updater = Mongoidable::AbilityUpdater.new(model, {
                                                  action: :action,
        subject: User,
        base_behavior: true,
        extra: [:name, { id: "merge|organization.user.id" }]
                                              })
    updater.call

    expect(model.instance_abilities.first).to be
    expect(model.instance_abilities.count).to eq 1
  end

  it "adds the ability if the extra merge args are different" do
    model.instance_abilities.create(
      action: :manage,
      subject: User,
      base_behavior: true,
      extra: [{ id: "merge|organization.user.id" }]
      )

    updater = Mongoidable::AbilityUpdater.new(model, {
                                                  action: :manage,
        subject: User,
        base_behavior: true,
        extra: [{ id: "merge|user.id" }]
                                              })
    updater.call

    expect(model.instance_abilities.count).to eq 2
  end

  it "adds the ability if the extra merge args are different same attributes" do
    model.instance_abilities.create(
      action: :manage,
      subject: User,
      base_behavior: true,
      extra: [:name, { id: "merge|organization.user.id" }]
      )

    updater = Mongoidable::AbilityUpdater.new(model, {
                                                  action: :manage,
        subject: User,
        base_behavior: true,
        extra: [:name, { id: "merge|user.id" }]
                                              })
    updater.call

    expect(model.instance_abilities.count).to eq 2
  end

  it "adds the ability if the attributes args are different" do
    model.instance_abilities.create(
      action: :manage,
      subject: User,
      base_behavior: true,
      extra: [:name]
      )

    updater = Mongoidable::AbilityUpdater.new(model, {
                                                  action: :manage,
        subject: User,
        base_behavior: true,
        extra: [:encrypted_password]
                                              })
    updater.call

    expect(model.instance_abilities.count).to eq 2
  end

  it "adds the ability if the attribute merge args are different" do
    model.instance_abilities.create(
      action: :manage,
      subject: User,
      base_behavior: true,
      extra: [:name, { id: "merge|organization.user.id" }]
      )

    updater = Mongoidable::AbilityUpdater.new(model, {
                                                  action: :manage,
        subject: User,
        base_behavior: true,
        extra: [:encrypted_password, { id: "merge|organization.user.id" }]
                                              })
    updater.call

    expect(model.instance_abilities.count).to eq 2
  end

  it "can store and check array type attributes" do
    user_1      = User.create(ids: [1, 2, 3, 4])
    user_2      = User.create(ids: [1])
    manage_user = User.create
    manage_user.instance_abilities.create! base_behavior: true, action: :an_action, subject: User, extra: [{ ids: 1 }]
    expect(manage_user.current_ability.can?(:an_action, user_1)).to be_truthy
    expect(manage_user.current_ability.can?(:an_action, user_2)).to be_truthy

    expect do
      manage_user.instance_abilities.update_ability base_behavior: true, action: :an_action, subject: User, extra: [{ ids: 1 }]
    end.not_to(change { manage_user.reload.instance_abilities.count })

    expect(manage_user.current_ability.can?(:an_action, user_1)).to be_truthy
    expect(manage_user.current_ability.can?(:an_action, user_2)).to be_truthy
  end

  it "can store and check array type attributes with attributes" do
    user_1      = User.create(ids: [1, 2, 3, 4])
    user_2      = User.create(ids: [1])
    manage_user = User.create
    manage_user.instance_abilities.create! base_behavior: true, action: :an_action, subject: User, extra: [:name, { ids: 1 }]
    expect(manage_user.current_ability.can?(:an_action, user_1, :name)).to be_truthy
    expect(manage_user.current_ability.can?(:an_action, user_2, :name)).to be_truthy

    expect do
      manage_user.instance_abilities.update_ability base_behavior: true, action: :an_action, subject: User, extra: [:name, { ids: 1 }]
    end.not_to(change { manage_user.reload.instance_abilities.count })

    expect(manage_user.current_ability.can?(:an_action, user_1, :name)).to be_truthy
    expect(manage_user.current_ability.can?(:an_action, user_2, :name)).to be_truthy
  end

  it "can store and check m2m relations" do
    many_relations = Array.new(4) { |index| ManyRelation.create(name: index.to_s) }
    user_1         = User.create(many_relations: many_relations)
    user_2         = User.create(many_relations: [many_relations[0]])
    manage_user    = User.create

    manage_user.
        instance_abilities.create! base_behavior: true, action: :an_action, subject: User, extra: [{ many_relation_ids: many_relations[0].id }]
    expect(manage_user.current_ability.can?(:an_action, user_1)).to be_truthy
    expect(manage_user.current_ability.can?(:an_action, user_2)).to be_truthy

    expect do
      manage_user.
          instance_abilities.
          update_ability base_behavior: true, action: :an_action, subject: User, extra: [{ many_relation_ids: many_relations[0].id }]
    end.not_to(change { manage_user.reload.instance_abilities.count })

    expect(manage_user.current_ability.can?(:an_action, user_1)).to be_truthy
    expect(manage_user.current_ability.can?(:an_action, user_2)).to be_truthy

    expect do
      manage_user.
          instance_abilities.
          update_ability base_behavior: false, action: :an_action, subject: User, extra: [{ many_relation_ids: many_relations[0].id }]
    end.to(change { manage_user.reload.instance_abilities.count }.by(-1))

    expect(manage_user.current_ability.can?(:an_action, user_1)).to be_falsey
    expect(manage_user.current_ability.can?(:an_action, user_2)).to be_falsey
  end

  it "can store and check m2m relations with attributes" do
    many_relations = Array.new(4) { |index| ManyRelation.create(name: index.to_s) }
    user_1         = User.create(many_relations: many_relations)
    user_2         = User.create(many_relations: [many_relations[0]])
    manage_user    = User.create

    manage_user.
        instance_abilities.create! base_behavior: true, action: :an_action, subject: User, extra: [:name, { many_relation_ids: many_relations[0].id }]
    expect(manage_user.current_ability.can?(:an_action, user_1, :name)).to be_truthy
    expect(manage_user.current_ability.can?(:an_action, user_2, :name)).to be_truthy

    expect do
      manage_user.
          instance_abilities.
          update_ability base_behavior: true, action: :an_action, subject: User, extra: [:name, { many_relation_ids: many_relations[0].id }]
    end.not_to(change { manage_user.reload.instance_abilities.count })

    expect(manage_user.current_ability.can?(:an_action, user_1, :name)).to be_truthy
    expect(manage_user.current_ability.can?(:an_action, user_2, :name)).to be_truthy

    expect do
      manage_user.
          instance_abilities.
          update_ability base_behavior: false, action: :an_action, subject: User, extra: [:name, { many_relation_ids: many_relations[0].id }]
    end.to(change { manage_user.reload.instance_abilities.count }.by(-1))

    expect(manage_user.current_ability.can?(:an_action, user_1, :name)).to be_falsey
    expect(manage_user.current_ability.can?(:an_action, user_2, :name)).to be_falsey
  end
end
