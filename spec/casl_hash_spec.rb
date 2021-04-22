# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"
RSpec.describe "casl_hash" do
  it "sets the action" do
    rule = CanCan::Rule.new(false, :action, User)
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash[:action]).to eq [:action]
  end

  it "sets the subject when a symbol" do
    rule = CanCan::Rule.new(false, :action, :subject)
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash[:subject]).to eq [:subject]
  end

  it "sets the subject when a class" do
    rule = CanCan::Rule.new(false, :action, User)
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash[:subject]).to eq ["User"]
  end

  it "sets the conditions when present" do
    rule = CanCan::Rule.new(false, :action, User, { id: 1 })
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash[:conditions]).to eq({ id: 1 })
  end

  it "camelizes the conditions when present" do
    rule = CanCan::Rule.new(false, :action, User, { end_user: { end_user_id: 1 } })
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash[:conditions]).to eq({ endUser: { endUserId: 1 } })
  end

  it "skips the conditions when not present" do
    rule = CanCan::Rule.new(false, :action, User)
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash.key?(:conditions)).to eq false
  end

  it "sets inverted when base_behavior is false" do
    rule = CanCan::Rule.new(false, :action, User)
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash[:inverted]).to be_truthy
  end

  it "skips inverted when base_behavior is true" do
    rule = CanCan::Rule.new(true, :action, User)
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash).not_to be_key(:inverted)
  end

  it "skips block when not present" do
    rule = CanCan::Rule.new(false, :action, User)
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash).not_to be_key(:block)
  end
end
