# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe "policies", :with_abilities do
  it "can store valid policy relations" do
    policy = Mongoidable::Policy.create(
      name: "policy",
      requires: {
        some_id: "ObjectId"
      },
      instance_abilities: [
        Mongoidable::Ability.create(base_behavior: true, action: :test, subject: :subject)
      ]
    )
    user = User.create(policies: [
      Mongoidable::PolicyRelation.new(required_data: {some_model: {id: 1} }, policy: policy)
    ])

    expect(user.policies.count).to eq(1)
    expect(user.policies.first.required_data).to eq({:some_model=>{:id=>1}})
  end

  # it "validates equal required data" do
  #   policy = Mongoidable::Policy.create(
  #     name: "policy",
  #
  #     instance_abilities: [
  #       Mongoidable::Ability.create(base_behavior: true, action: :test, subject: :subject)
  #     ]
  #   )
  #   user = User.new(policies: [
  #     Mongoidable::PolicyRelation.new(required_data: {some_model: {id: 1} }, policy: policy)
  #   ])
  #
  #   expect(user).to be_valid
  # end

  it "generates correct current_abilities" do
    policy = Mongoidable::Policy.create(
      name: "policy",
      requires: {
        some_id: "ObjectId"
      },
      instance_abilities: [
        Mongoidable::Ability.create(base_behavior: true, action: :test, subject: :subject)
      ]
    )
    user = User.create(policies: [
      Mongoidable::PolicyRelation.new(required_data: {some_model: {id: 1} }, policy: policy)
    ])

    user.current_ability
  end
end