# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::PolicySerializer do
  it "serializes the correct fields on a policy" do
    policy = Mongoidable::Policy.new(_id: "id",
                                     name: "New Policy",
                             description: "Policy description",
                             type: Object,
                             instance_abilities: [Mongoidable::Ability.new(
                               base_behavior: true,
                               action: :action,
                               subject: :subject,
                               id: "ability_id")])

    output = Mongoidable::PolicySerializer.new(policy).as_json

    expect(output[:_id]).to eq policy.id.to_s
    expect(output[:name]).to eq policy.name.to_s
    expect(output[:description]).to eq policy.description.to_s
    expect(output[:type]).to eq policy.type.to_s
    expect(output[:instance_abilities]).to eq ["ability_id"]
  end
end