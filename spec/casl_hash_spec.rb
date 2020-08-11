# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"
RSpec.describe "casl_hash" do
  it "sets the action" do
    rule = CanCan::Rule.new(false, :action, User)
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash[:actions]).to eq [:action]
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
  it "skips the conditions when not present" do
    rule = CanCan::Rule.new(false, :action, User)
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash[:conditions]).not_to be
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

  it "adds the block as js when present" do
    rule = CanCan::Rule.new(false, :action, User) do
      1 + 1
    end
    hash = Mongoidable::CaslHash.new(rule)
    expect(hash[:block]).to eq "var rule = new CanCan.Rule(false, \"action\", User, function() {\n  return 1 + 1\n})"
  end
end
