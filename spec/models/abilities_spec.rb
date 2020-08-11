# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::Abilities do
  describe "to_list" do
    it "produces a casl list of rules" do
      abilities = Mongoidable::Abilities.new
      abilities.can(:do_thing, :to_thing)
      abilities.cannot(:do_other_thing, User, { name: "Fred" })
      abilities.can(:do_block_thing, User) do |user|
        user.name == "Fred"
      end

      expect(abilities.to_casl_list).to eq(
          [
              {
                  actions:   [:do_thing],
                  subject:   [:to_thing],
                  has_block: false
              },
              {
                  actions:    [:do_other_thing],
                  conditions: { name: "Fred" },
                  inverted:   true,
                  subject:    ["User"],
                  has_block:  false
              },
              {
                  actions:    [:do_block_thing],
                  subject:    ["User"],
                  has_block:  true,
                  block_js:   "abilities.can(\"do_block_thing\", User, function(user) {\n  return user.name == \"Fred\"\n})",
                  block_ruby: "abilities.can(:do_block_thing, User) do |user|\n        user.name == \"Fred\"\n      end"
              }
          ]
        )
    end

    it "produces a casl list of rules without js closure" do
      allow(Mongoidable.configuration).to receive(:serialize_js).and_return(false)

      abilities = Mongoidable::Abilities.new
      abilities.can(:do_thing, :to_thing)
      abilities.cannot(:do_other_thing, User, { name: "Fred" })
      abilities.can(:do_block_thing, User) do |user|
        user.name == "Fred"
      end

      expect(abilities.to_casl_list).to eq(
          [
              {
                  actions:   [:do_thing],
                  subject:   [:to_thing],
                  has_block: false
              },
              {
                  actions:    [:do_other_thing],
                  conditions: { name: "Fred" },
                  inverted:   true,
                  subject:    ["User"],
                  has_block:  false
              },
              {
                  actions:    [:do_block_thing],
                  subject:    ["User"],
                  has_block:  true,
                  block_ruby: "abilities.can(:do_block_thing, User) do |user|\n        user.name == \"Fred\"\n      end"
              }
          ]
        )
    end

    it "produces a casl list of rules without ruby block" do
      allow(Mongoidable.configuration).to receive(:serialize_ruby).and_return(false)

      abilities = Mongoidable::Abilities.new
      abilities.can(:do_thing, :to_thing)
      abilities.cannot(:do_other_thing, User, { name: "Fred" })
      abilities.can(:do_block_thing, User) do |user|
        user.name == "Fred"
      end

      expect(abilities.to_casl_list).to eq(
          [
              {
                  actions:   [:do_thing],
                  subject:   [:to_thing],
                  has_block: false
              },
              {
                  actions:    [:do_other_thing],
                  conditions: { name: "Fred" },
                  inverted:   true,
                  subject:    ["User"],
                  has_block:  false
              },
              {
                  actions:   [:do_block_thing],
                  subject:   ["User"],
                  has_block: true,
                  block_js:  "abilities.can(\"do_block_thing\", User, function(user) {\n  return user.name == \"Fred\"\n})"
              }
          ]
        )
    end
  end
end
