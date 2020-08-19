# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::Abilities do
  describe "to_list" do
    let(:expected_result) do
      [
          {
              type:        :adhoc,
              source:      "test",
              has_block:   false,
              subject:     [:to_thing],
              actions:     [:do_thing],
              description: "translation missing: en.mongoidable.do_thing"
          },
          {
              type:        :adhoc,
              source:      "test",
              has_block:   false,
              inverted:    true,
              conditions:  { name: "Fred" },
              subject:     ["User"],
              actions:     [:do_other_thing],
              description: "translation missing: en.mongoidable.do_other_thing"
          },
          {
              type:        :adhoc,
              source:      "test",
              has_block:   true,
              block_ruby:  "abilities.can(:do_block_thing, User) do |user|\n        user.name == \"Fred\"\n      end",
              block_js:    "abilities.can(\"do_block_thing\", User, function(user) {\n  return user.name == \"Fred\"\n})",
              subject:     ["User"],
              actions:     [:do_block_thing],
              description: "translation missing: en.mongoidable.do_block_thing"
          }
      ]
    end
    it "produces a casl list of rules" do
      abilities = Mongoidable::Abilities.new("test")
      abilities.can(:do_thing, :to_thing)
      abilities.cannot(:do_other_thing, User, { name: "Fred" })
      abilities.can(:do_block_thing, User) do |user|
        user.name == "Fred"
      end
      expect(abilities.to_casl_list).to eq(expected_result)
    end

    it "produces a casl list of rules without js closure" do
      allow(Mongoidable.configuration).to receive(:serialize_js).and_return(false)

      abilities = Mongoidable::Abilities.new("test")
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

      abilities = Mongoidable::Abilities.new("test")
      abilities.can(:do_thing, :to_thing)
      abilities.cannot(:do_other_thing, User, { name: "Fred" })
      abilities.can(:do_block_thing, User) do |user|
        user.name == "Fred"
      end

      expected_result[2].delete(:block_ruby)

      expect(abilities.to_casl_list).to eq(expected_result)
    end
  end
end
