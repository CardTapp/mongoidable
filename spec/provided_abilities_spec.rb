# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe "current_ability", :with_abilities do
  it "provides the ability" do
    parent = Parent1.new
    user = User.new

    parent.user_provided_abilities.update_ability(base_behavior: true, action: :provided_action, subject: :provided_subject)
    expect(parent.current_ability).to be_cannot(:provided_action, :some_subject)
    expect(user.current_ability).to be_cannot(:provided_action, :provided_subject)

    user.parent1 = parent
    user.save
    parent.save
    expect(user.current_ability).to be_can(:provided_action, :provided_subject)
  end
end