# frozen_string_literal: true

require "rails_helper"
require "mongoidable"
require "devise/test_helpers"
RSpec.describe Mongoidable::AbilitiesController, type: :controller do
  routes { Mongoidable::Engine.routes }

  let(:other_user) do
    User.create(instance_abilities: [
                    Mongoidable::Ability.create(base_behavior: true, action: :read, subject: Parent1)
                ])
  end
  let(:user) do
    User.create(instance_abilities: [
                    Mongoidable::Ability.create(base_behavior: true, action: :manage_abilities, subject: User),
                    Mongoidable::Ability.create(base_behavior: true, action: :read_abilities, subject: User)
                ])
  end

  describe "authorization" do
    before { allow(subject).to receive(:current_user).and_return user }

    it do
      user = User.create
      expect(subject).to authorize(:read_abilities, instance_variable(:request_object)).for(
          :index, owner_id: user.id.to_s, owner_type: "user"
        ).run_actions(:request_object)
      expect(instance_variable(:request_object).variable_value).to eq user
    end

    it do
      user = User.create
      expect(subject).to authorize(:manage_abilities, instance_variable(:request_object)).for(
          :create, owner_id: user.id.to_s, owner_type: "user"
        ).run_actions(:request_object)
      expect(instance_variable(:request_object).variable_value).to eq user
    end
  end

  describe "actions" do
    before { sign_in user }

    describe "index" do
      it "returns abilities for the user" do
        other_user.instance_abilities.create(base_behavior: true, action: :action, subject: :subject)
        get :index, params: { owner_id: other_user.id.to_s, owner_type: "user" }

        expect(response).to be_ok
        abilities = JSON.parse(response.body)["instance-abilities"]
        database_abilities = other_user.instance_abilities
        expect(abilities.size).to eq(database_abilities.size)
        abilities.each_with_index do |ability, index|
          expect(ability["action"]).to eq(database_abilities[index][:action].to_s)
          expect(ability["subject"]).to eq(database_abilities[index].attributes["subject"].stringify_keys)
        end
      end
    end

    describe "create" do
      it "gives the specified user the specified ability" do
        expect(other_user.current_ability.can?(:test, Object)).to be_falsy

        put :create, params: {
            owner_id:           other_user.id.to_s,
            owner_type:         "user",
            instance_abilities: [{
                action:  :test,
                subject: { type: "class", value: "Object" },
                enabled: true
            }]
        }, as: :json

        expect(response).to be_ok
        other_user.reload
        expect(other_user.current_ability.can?(:test, Object)).to be_truthy
      end

      it "revokes the specified ability from the specified user" do
        ability_args = { base_behavior: true, action: :action, subject: { type: "symbol", value: "subject" } }
        test_ability = other_user.instance_abilities.create(ability_args)

        expect(other_user.current_ability.can?(test_ability.action, test_ability.subject)).to be_truthy

        put :create, params: {
            owner_id:           other_user.id.to_s,
            owner_type:         "user",
            instance_abilities: [{
                action:        test_ability.action,
                subject:       { type: "symbol", value: "subject" },
                base_behavior: false
            }]
        }, as: :json

        expect(response).to be_ok
        other_user.reload
        expect(other_user.current_ability).to be_cannot(test_ability.action, test_ability.subject)
      end

      it "removes the policy" do
        policy_1 = Mongoidable::Policy.create(
            name:               "policy_one",
            owner_type:         "user",
            requirements:       {
                user: { id: "ObjectId" }
            },
            instance_abilities: [Mongoidable::Ability.new(base_behavior: true, action: :action_one, subject: User, extra: [{ id: "merge|user.id" }])]
          )

        other_user.policies.create(
            requirements: { user: { id: 1 } },
            policy_id:    policy_1.id
          )

        expect(other_user.current_ability).to be_can(:action_one, User.new(id: 1))
        expect(other_user.current_ability).to be_cannot(:action_two, User.new(id: 1))

        put :create, params: {
            owner_id:        other_user.id.to_s,
            owner_type:      "user",
            policy_relation: "policies",
            policy_id:       policy_1.id.to_s,
            requirements:    { user: { id: 1 } },
            remove_policy:   "true"
        }, as: :json

        other_user.reload
        expect(other_user.policies.count).to eq 0
      end

      it "applies the policy" do
        database_policy = Mongoidable::Policy.create(
            name:               "policy",
            owner_type:         "user",
            requirements:       {
                user: { id: "ObjectId" }
            },
            instance_abilities: [Mongoidable::Ability.new(base_behavior: true, action: :action, subject: User, extra: [{ id: "merge|user.id" }])]
          )

        put :create, params: {
            owner_id:        other_user.id.to_s,
            owner_type:      "user",
            policy_relation: "policies",
            policy_id:       database_policy.id.to_s,
            requirements:    { user: { id: 1 } }
        }, as: :json

        other_user.reload
        expect(other_user.policies.count).to eq 1

        expect(other_user.current_ability).to be_can(:action, User.new(id: 1))
        expect(other_user.current_ability).to be_cannot(:action, User.new(id: 2))
      end
    end
  end
end
