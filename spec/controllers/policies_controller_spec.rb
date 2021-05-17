# frozen_string_literal: true

require "rails_helper"
require "mongoidable"

RSpec.describe Mongoidable::PoliciesController, type: :controller do
  routes { Mongoidable::Engine.routes }

  let(:user) { User.create }

  describe "authorization" do
    let(:policy) { double(Mongoidable::Policy) }

    it {
      allow(Mongoidable::Policy).to receive(:find_by).with({ owner_type: "user" }).and_return(policy)
      expect(subject).to authorize(:index, Mongoidable::Policy).
          for("index", owner_type: "user", format: :json).run_actions(:policy)
    }

    it {
      allow(Mongoidable::Policy).to receive(:find_by).with({ id: 1 }).and_return(policy)
      expect(subject).to authorize(:show, policy).
          for("show", id: 1, format: :json).run_actions(:policy)
    }

    it {
      allow(Mongoidable::Policy).to receive(:new).and_return(policy)
      expect(subject).to authorize(:create, policy).
          for("create", policy: { name: "test" }, format: :json).run_actions(:policy)
    }

    it {
      allow(subject).to receive(:current_user).and_return User.new
      allow(Mongoidable::Policy).to receive(:find_by).with({ id: 1 }).and_return(policy)
      allow(policy).to receive(:subscribe)
      expect(subject).to authorize(:update, policy).
          for("update", id: 1, format: :json).run_actions(:policy)
    }

    it {
      allow(Mongoidable::Policy).to receive(:find_by).with({ id: 1 }).and_return(policy)
      expect(subject).to authorize(:destroy, policy).
          for("destroy", id: 1, format: :json).run_actions(:policy)
    }
  end

  describe "actions" do
    before do
      user.instance_abilities.create(base_behavior: true, action: :manage, subject: Mongoidable::Policy)
      sign_in user
    end

    describe "custom query" do
      routes { Mongoidable::Engine.routes }

      class CustomPolicyQuery < Mongoidable::PolicyQuery
        def object_for_index
          super.where(name: "only me")
        end
      end

      around(:each) do |example|
        orig_policy_query = Mongoidable.configuration.policy_query

        example.run
      ensure
        Mongoidable.configuration.policy_query = orig_policy_query
      end

      it "uses the custom policies query" do
        Mongoidable.configuration.policy_query = "CustomPolicyQuery"

        Mongoidable::Policy.create(
            name:               "not me",
            owner_type:         "user",
            instance_abilities: [Mongoidable::Ability.new(base_behavior: true, action: :action, subject: { type: "symbol", value: "subject" })]
        )
        Mongoidable::Policy.create(
            name:               "only me",
            owner_type:         "user",
            instance_abilities: [Mongoidable::Ability.new(base_behavior: true, action: :action, subject: { type: "symbol", value: "subject" })]
        )

        get :index, params: { owner_type: "user" }

        expect(response).to be_ok

        policies = JSON.parse(response.body)["policies"]

        expect(policies.length).to eq 1
        expect(policies[0]["name"]).to eq "only me"
      end
    end

    describe "index" do
      routes { Mongoidable::Engine.routes }
      it "returns user type policies" do
        database_policies = 10.times do |index|
          Mongoidable::Policy.create(
              name:               index,
              owner_type:         "user",
              instance_abilities: [Mongoidable::Ability.new(base_behavior: true, action: :action, subject: { type: "symbol", value: "subject" })]
            )
        end

        get :index, params: { owner_type: "user" }
        expect(response).to be_ok
        policies = JSON.parse(response.body)["abilities/policies"]
        verify_policies(policies, database_policies)
      rescue StandardError => error
        error
      end
    end

    describe "show" do
      it "returns the requested policy" do
        database_policy = Mongoidable::Policy.create(
            name:               "policy",
            owner_type:         "user",
            instance_abilities: [Mongoidable::Ability.new(base_behavior: true, action: :action, subject: { type: "symbol", value: "subject" })]
          )

        get :show, params: { id: database_policy.id.to_s, owner_type: database_policy.owner_type }

        expect(response).to be_ok
        policy = JSON.parse(response.body)["policy"]
        verify_policies(policy, database_policy)
      end
    end

    describe "update" do
      it "adds abilities" do
        database_policy = Mongoidable::Policy.create(
            name:               "policy",
            owner_type:         "user",
            instance_abilities: [Mongoidable::Ability.new(base_behavior: true, action: :action, subject: { type: "symbol", value: "subject" })]
          )

        new_abilites = 3.times.map do |index|
          Mongoidable::Ability.create(base_behavior: true, action: index.to_s, subject: { "type" => "symbol", value: "subject" }).attributes
        end

        put :update, params: {
            id:                 database_policy.id.to_s,
            owner_type:         database_policy.owner_type,
            replace:            false,
            instance_abilities: new_abilites
        }

        database_policy.reload

        expect(response).to be_ok
        policy = JSON.parse(response.body)["policy"]
        verify_policies(policy, database_policy)
        expect(database_policy.instance_abilities.length).to eq 4
      end

      it "removes abilities" do
        database_policy = Mongoidable::Policy.create(
            name:               "policy",
            owner_type:         "user",
            instance_abilities: [Mongoidable::Ability.new(base_behavior: true, action: :action, subject: { type: "symbol", value: "subject" })]
          )

        removed_ability = database_policy.instance_abilities.first.attributes
        removed_ability["base_behavior"] = false
        put :update, params: {
            id:                 database_policy.id.to_s,
            owner_type:         database_policy.owner_type,
            replace:            false,
            instance_abilities: [removed_ability]
        }

        database_policy.reload

        expect(response).to be_ok
        policy = JSON.parse(response.body)["policy"]
        verify_policies(policy, database_policy)
        expect(database_policy.instance_abilities.length).to eq 0
      end
    end

    describe "destroy" do
      it "destroys the policy" do
        database_policy = Mongoidable::Policy.create(
            name:               "policy",
            owner_type:         "user",
            instance_abilities: [Mongoidable::Ability.new(base_behavior: true, action: :action, subject: { type: "symbol", value: "subject" })]
          )

        put :destroy, params: {
            id:         database_policy.id.to_s,
            owner_type: database_policy.owner_type
        }

        expect(Mongoidable::Policy.all.count).to eq 0
      end
    end

    # rubocop:disable Metrics/AbcSize
    def verify_policies(response_policies, db_policies)
      response_policies = Array.wrap(response_policies)
      db_policies = Array.wrap(db_policies)

      response_policies.each do |policy|
        db_policy = db_policies.detect { |db| policy["_id"] == db.id.to_s }
        expect(policy["name"]).to eq(db_policy["name"])
        expect(policy["type"]).to eq("user")

        db_abilities = db_policy.instance_abilities.to_a
        policy["abilities"].each_with_index do |ability, index|
          db_ability = db_abilities[index]
          expect(ability["action"].first).to eq(db_ability.action.to_s)
          expect(ability["subject"].first).to eq(db_ability.subject.to_s)
          expect(ability["inverted"]).to eq(true) if db_ability.base_behavior == false
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
