# frozen_string_literal: true

require "rails_helper"
require "mongoidable"

RSpec.describe Mongoidable::PoliciesController, :authorizes_controller, type: :controller do
  routes { Mongoidable::Engine.routes }
  let(:user) { User.create }

  describe "authorization" do
    let(:policy) { double(Mongoidable::Policy) }
    before do
    end
    it {
      allow(Mongoidable::Policy).to receive(:find_by).with({ "policy_type"=>"user" }).and_return(policy)
      is_expected.to authorize(:index, Abilities::Policy).
          for("index", policy_type: "user", format: :json).run_actions(:policy)
    }
    it {
      allow(Mongoidable::Policy).to receive(:find_by).with({ "id"=>1 }).and_return(policy)
      is_expected.to authorize(:show, policy).
          for("show", id: 1, format: :json).run_actions(:policy)
    }
    it {
      allow(Mongoidable::Policy).to receive(:new).and_return(policy)
      is_expected.to authorize(:create, policy).
          for("create", policy: { name: "test" }, format: :json).run_actions(:policy)
    }
    it {
      allow(Mongoidable::Policy).to receive(:find_by).with({ "id"=>1 }).and_return(policy)
      allow(policy).to receive(:subscribe)
      is_expected.to authorize(:update, policy).
          for("update", id: 1, format: :json).run_actions(:policy)
    }
    it {
      allow(Mongoidable::Policy).to receive(:find_by).with({ "id"=>1 }).and_return(policy)
      is_expected.to authorize(:destroy, policy).
          for("destroy", id: 1, format: :json).run_actions(:policy)
    }
  end

  describe "actions" do
    before { sign_in user }
    describe "index" do
      it "returns user type policies" do
        database_policies = FactoryBot.create_list(:policy, 10, :with_abilities, count: 3)

        get :index, params: { type: "user" }
        expect(response).to be_ok
        policies = JSON.parse(response.body)["abilities/policies"]
        verify_policies(policies, database_policies)
      end
    end

    describe "show" do
      it "returns the requested policy" do
        database_policy = FactoryBot.create(:policy, :with_abilities, count: 3)
        get :show, params: { id: database_policy.id.to_s, type: database_policy.type }

        expect(response).to be_ok
        policy = JSON.parse(response.body)["policy"]
        verify_policies(policy, database_policy)
      end
    end

    describe "update" do
      it "overwrites with the new policy abilities " do
        database_policy = FactoryBot.create(:policy, :with_abilities, count: 3, base_behavior: true)

        new_abilites = FactoryBot.build_list(:ability, 3, base_behavior: true).map { |ability| ability.attributes.to_h }

        put :update, params: {
            id:                 database_policy.id.to_s,
            type:               database_policy.type,
            replace:            true,
            instance_abilities: new_abilites
        }

        database_policy.reload

        expect(response).to be_ok
        policy = JSON.parse(response.body)["policy"]
        verify_policies(policy, database_policy)
        expect(database_policy.instance_abilities.length).to eq new_abilites.length
      end

      it "adds abilities" do
        database_policy = FactoryBot.create(:policy, :with_abilities, count: 3, base_behavior: true)

        new_abilites = FactoryBot.build_list(:ability, 3, base_behavior: true).map(&:attributes)

        put :update, params: {
            id:                 database_policy.id.to_s,
            type:               database_policy.type,
            replace:            false,
            instance_abilities: new_abilites
        }

        database_policy.reload

        expect(response).to be_ok
        policy = JSON.parse(response.body)["policy"]
        verify_policies(policy, database_policy)
        expect(database_policy.instance_abilities.length).to eq 6
      end

      it "removes abilities" do
        database_policy = FactoryBot.create(:policy, :with_abilities, count: 3, base_behavior: true)

        removed_ability = database_policy.instance_abilities.first.attributes
        removed_ability["base_behavior"] = false
        put :update, params: {
            id:                 database_policy.id.to_s,
            type:               database_policy.type,
            replace:            false,
            instance_abilities: [removed_ability]
        }

        database_policy.reload

        expect(response).to be_ok
        policy = JSON.parse(response.body)["policy"]
        verify_policies(policy, database_policy)
        expect(database_policy.instance_abilities.length).to eq 2
      end
    end

    describe "destroy" do
      it "destroys the policy" do
        database_policy = FactoryBot.create(:policy, :with_abilities, count: 3)
        put :destroy, params: {
            id:   database_policy.id.to_s,
            type: database_policy.type
        }

        expect(Abilities::Policy.all.count).to eq 0
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
