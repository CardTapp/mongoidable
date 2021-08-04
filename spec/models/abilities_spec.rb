# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::Abilities do
  let(:abilities) { Mongoidable::Abilities.new("test", nil) }

  describe "to_casl_list" do
    let(:expected_result) do
      [
          {
              type:        :adhoc,
              source:      "test",
              has_block:   false,
              subject:     [:to_thing],
              action:      [:do_thing],
              description: "translation missing: en.mongoidable.ability.description.do_thing"
          },
          {
              type:        :adhoc,
              source:      "test",
              has_block:   false,
              inverted:    true,
              conditions:  { name: "Fred" },
              subject:     ["User"],
              action:      [:do_other_thing],
              description: "translation missing: en.mongoidable.ability.description.do_other_thing"
          },
          {
              type:        :adhoc,
              source:      "test",
              has_block:   true,
              block_ruby:  "abilities.can(:do_block_thing, User) do |user|\n        user.name == \"Fred\"\n      end",
              block_js:    "abilities.can(\"do_block_thing\", User, function(user) {\n  return user.name == \"Fred\"\n})",
              subject:     ["User"],
              action:      [:do_block_thing],
              description: "translation missing: en.mongoidable.ability.description.do_block_thing"
          }
      ]
    end

    it "produces a casl list of rules" do
      abilities.can(:do_thing, :to_thing)
      abilities.cannot(:do_other_thing, User, { name: "Fred" })
      abilities.can(:do_block_thing, User) do |user|
        user.name == "Fred"
      end
      expect(abilities.to_casl_list).to eq(expected_result)
    end

    it "produces a casl list of rules without js closure" do
      allow(Mongoidable.configuration).to receive(:serialize_js).and_return(false)

      abilities.can(:do_thing, :to_thing)
      abilities.cannot(:do_other_thing, User, { name: "Fred" })
      abilities.can(:do_block_thing, User) do |user|
        user.name == "Fred"
      end

      expected_result[2].delete(:block_js)

      expect(abilities.to_casl_list).to eq(expected_result)
    end

    it "produces a casl list of rules without ruby block" do
      allow(Mongoidable.configuration).to receive(:serialize_ruby).and_return(false)

      abilities.can(:do_thing, :to_thing)
      abilities.cannot(:do_other_thing, User, { name: "Fred" })
      abilities.can(:do_block_thing, User) do |user|
        user.name == "Fred"
      end

      expected_result[2].delete(:block_ruby)

      expect(abilities.to_casl_list).to eq(expected_result)
    end
  end

  describe "can?" do
    before { allow(abilities).to receive(:ability_cache_key).and_return("") }

    it "checks if it can cache" do
      expect(abilities).to receive(:can_cache?).and_return false
      abilities.can?(:test_action, :test_subject)
    end

    it "uses cache if possible" do
      expect(abilities).to receive(:can_cache?).and_return true
      expect(Rails.cache).to receive(:fetch).and_return true
      abilities.can?(:test_action, :test_subject)
    end
  end

  describe "can" do
    it "add sets the ability source and type" do
      abilities.can(:action, :subject)
      rule = abilities.instance_variable_get(:@rules).first
      expect(rule.instance_variable_get(:@rule_source)).to eq "test"
      expect(rule.instance_variable_get(:@rule_type)).to eq :adhoc
    end
  end

  describe "reset" do
    it "resets rules and rule indexes" do
      abilities = described_class.new("test", nil)
      abilities.reset
      expect(abilities.instance_variable_get(:@rules)).to be_nil
      expect(abilities.instance_variable_get(:@rules_index)).to be_nil
    end
  end
end
