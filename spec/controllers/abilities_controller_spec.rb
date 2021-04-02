# frozen_string_literal: true

require "rails_helper"
require "mongoidable"

RSpec.describe Mongoidable::AbilitiesController, :authorizes_controller, type: :controller do
  routes { Mongoidable::Engine.routes }
  let(:disallowed_user) do
    other_user = User.create
    other_user.instance_abilities.create(base_behavior: true, action: :read, subject: Parent1)
    other_user.save
    other_user
  end
  let(:user) { User.create }

  describe "authorization" do
    before { allow(subject).to receive(:current_user).and_return(user) }
    it do
      user = User.create
      is_expected.to authorize(:index_abilities, instance_variable(:request_object)).for(
          :index, owner_id: user.id.to_s, type: "user"
        )
      expect(instance_variable(:request_object).variable_value).to eq user
    end

    it do
      user = User.create
      is_expected.to authorize(:update_abilities, instance_variable(:request_object)).for(
          :create, owner_id: user.id.to_s, type: "user"
        )
      expect(instance_variable(:request_object).variable_value).to eq user
    end
  end

  describe "actions" do
    before { sign_in user }
    describe "index" do
      it "returns abilities for the user" do
        disallowed_user.instance_abilities.create(base_behavior: true, action: :action, subject: :subject)
        get :index, params: { owner_id: disallowed_user.id.to_s, type: "user" }

        expect(response).to be_ok
        abilities = JSON.parse(response.body)["instance-abilities"]
        database_abilities = disallowed_user.instance_abilities
        expect(abilities.size).to eq(database_abilities.size)
        abilities.each_with_index do |ability, index|
          expect(ability["action"]).to eq(database_abilities[index][:action].to_s)
          expect(ability["subject"]).to eq(Mongoidable::ClassType.demongoize(database_abilities[index][:subject]).to_s)
        end
      end
    end

    describe "create" do
      it "gives the specified user the specified ability" do
        expect(disallowed_user.current_ability.can?(:test, Object)).to be_falsy

        put :create, params: {
            owner_id:             disallowed_user.id.to_s,
            type:                 "user",
            "instance_abilities": [{
                action:  :test,
                subject: { type: "class", value: "Object" },
                enabled: true
            }]
        }, as: :json

        expect(response).to be_ok
        Rails.cache.clear
        disallowed_user.reload
        expect(disallowed_user.current_ability.can?(:test, Object)).to be_truthy
      end

      it "revokes the specified ability from the specified user" do
        ability_args = { base_behavior: true, action: :action, subject: { type: "symbol", value: "subject" } }
        test_ability = disallowed_user.instance_abilities.create(ability_args)

        expect(disallowed_user.current_ability.can?(test_ability.action, test_ability.subject)).to be_truthy

        put :create, params: {
            owner_id:             disallowed_user.id.to_s,
            type:                 "user",
            "instance_abilities": [{
                action:        test_ability.action,
                subject:       { type: "symbol", value: "subject" },
                base_behavior: false
            }]
        }, as: :json

        expect(response).to be_ok
        Rails.cache.clear
        disallowed_user.reload
        expect(disallowed_user.current_ability).to be_cannot(test_ability.action, test_ability.subject)
      end
    end
  end
end
