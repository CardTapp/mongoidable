# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::ClassType do
  describe "mongoize" do
    it "does not change a string representation of a class" do
      expect(described_class.mongoize(described_class.name)).to eq({ type: "string", value: "Mongoidable::ClassType" })
    end

    it "converts a module" do
      expect(described_class.mongoize(Mongoidable::Document)).to eq({ type: "module", value: "Mongoidable::Document" })
    end

    it "converts a ability" do
      expect(described_class.mongoize(Mongoidable::Ability)).to eq({ type: "class", value: "Mongoidable::Ability" })
    end

    it "converts nil to nil" do
      expect(described_class.mongoize(nil)).to eq({ type: "nil", value: nil })
    end

    it "converts a symbol" do
      expect(described_class.mongoize(:asdf)).to eq({ type: "symbol", value: "asdf" })
    end

    it "converts a string" do
      expect(described_class.mongoize("asdf")).to eq({ type: "string", value: "asdf" })
    end
  end

  describe "demongoize" do
    it "converts to a module" do
      expect(described_class.demongoize({ type: "module", value: "Mongoidable::Document" })).to eq Mongoidable::Document
    end

    it "converts to a class" do
      expect(described_class.demongoize({ type: "class", value: "Mongoidable::Ability" })).to eq Mongoidable::Ability
    end

    it "converts to nil" do
      expect(described_class.demongoize({ type: "nil", value: nil })).to eq nil
    end

    it "converts to a symbol" do
      expect(described_class.demongoize({ type: "symbol", value: "asdf" })).to eq :asdf
    end

    it "converts to a string" do
      expect(described_class.demongoize({ type: "string", value: "asdf" })).to eq "asdf"
    end
  end
end