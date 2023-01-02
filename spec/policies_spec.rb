# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe "policies", :with_abilities do
  it "can store valid policy relations" do
    policy = Mongoidable::Policy.create(
      name: "policy",
      requirements: {
          some_id: "ObjectId"
      },
      instance_abilities: [
          Mongoidable::Ability.create(base_behavior: true, action: :test, subject: :subject)
      ]
    )
    user = User.create(policies: [
                           Mongoidable::PolicyRelation.new(requirements: { some_model: { id: 1 } }, policy: policy)
                       ])

    expect(user.policies.count).to eq(1)
    expect(user.policies.first.requirements).to eq({ some_model: { id: 1 } })
  end

  it "generates correct current_abilities" do
    policy = Mongoidable::Policy.create(
      name: "policy",
      requirements: {
          id: "ObjectId"
      },
      instance_abilities: [
          Mongoidable::Ability.create(base_behavior: true, action: :test, subject: User, extra: [{ id: "merge|id" }])
      ]
    )
    user = User.create(policies: [
                           Mongoidable::PolicyRelation.new(requirements: { id: 1 }, policy: policy)
                       ])

    expect(user.policies[0].policy.instance_abilities[0].extra[0][:id]).to eq "merge|id"
    expect(user.current_ability).to be_can(:test, User.new(id: 1))
    expect(user.current_ability).to be_cannot(:test, User.new(id: 2))
    expect(user.policies[0].policy.instance_abilities[0].extra[0][:id]).to eq "merge|id"
  end

  it "generates correct current_abilities with attributes" do
    policy = Mongoidable::Policy.create(
      name: "policy",
      requirements: {
          id: "ObjectId"
      },
      instance_abilities: [
          Mongoidable::Ability.create(base_behavior: true, action: :test, subject: User, extra: [:name, { id: "merge|id" }])
      ]
    )
    user = User.create(policies: [
                           Mongoidable::PolicyRelation.new(requirements: { id: 1 }, policy: policy)
                       ])

    expect(user.policies[0].policy.instance_abilities[0].extra[1][:id]).to eq "merge|id"
    expect(user.current_ability).to be_can(:test, User.new(id: 1), :name)
    expect(user.current_ability).to be_cannot(:test, User.new(id: 2), :name)
    expect(user.policies[0].policy.instance_abilities[0].extra[1][:id]).to eq "merge|id"
  end
end
