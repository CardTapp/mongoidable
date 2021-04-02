# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::AbilityQuery do
  describe "query" do
    let(:ability) { Mongoidable::Ability.new(base_behavior: true, action: "test", subject: Object) }
    let(:user) { User.create }

    before do
      user.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :crud_abilities, subject: :ability)
    end

    describe "for document" do
      let(:params) do
        ActionController::Parameters.new({ owner_type: "user", owner_id: user.id.to_s, instance_abilities: [{
                                             "action"  => "test",
                                             "subject" => { type: "symbol", value: "ability" },
                                             "enabled" => "true"
                                         }] })
      end
      let(:query) { Mongoidable::AbilityQuery.new(user, params) }

      describe "object_for_index" do
        it "returns abilities for the document type" do
          user.instance_abilities << ability
          user.save!
          abilities = query.object_for_index.current_ability.to_casl_list
          database_abilities = user.current_ability.to_casl_list
          expect(abilities).to eq database_abilities
        end
      end

      describe "object_for_update" do
        it "gives the specified user the specified ability" do
          object = query.object_for_update
          user.current_ability.authorize! :crud_abilities, :ability
          expect(object.current_ability.can?(:test, :ability)).to be_truthy
        end

        it "gives the specified user the specified typed ability" do
          params = ActionController::Parameters.new({ owner_type: "user", owner_id: user.id.to_s, instance_abilities: [{
                                                        "action"  => "organization_owner",
                                                        "subject" => { type: "symbol", value: "ability" },
                                                        "enabled" => "true"
                                                    }] })
          query = Mongoidable::AbilityQuery.new(user, params)
          object = query.object_for_update
          user.current_ability.authorize! :crud_abilities, :ability
          expect(object.current_ability.can?(:organization_owner, :ability)).to be_truthy
        end

        it "revokes the specified ability from the specified user" do
          params = ActionController::Parameters.new({ owner_type: "user", owner_id: user.id.to_s, instance_abilities: [{
                                                        "action"  => "organization_owner",
                                                        "subject" => { type: "symbol", value: "ability" },
                                                        "enabled" => "false"
                                                    }] })
          query = Mongoidable::AbilityQuery.new(user, params)
          user = query.object_for_update
          user.current_ability.authorize! :crud_abilities, :ability
          user.reload

          expect(user.current_ability.can?(:test, Object)).to be_falsy
        end
      end
    end
  end
end
