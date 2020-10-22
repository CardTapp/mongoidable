# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::ClassType do
  describe "mongoize" do
    it "does not change a string representation of a class" do
      expect(described_class.mongoize("Mongoidable::ClassType")).to eq "Mongoidable::ClassType"
    end

    it "converts a class to a string" do
      expect(described_class.mongoize(described_class)).to eq "Mongoidable::ClassType"
    end

    it "converts nil to empty string" do
      expect(described_class.mongoize(nil)).to eq ""
    end

    it "converts a symbol to a string" do
      expect(described_class.mongoize(:asdf)).to eq "asdf"
    end
  end

  describe "demongoize" do
    it "converts a string to a class" do
      expect(described_class.demongoize("Mongoidable::ClassType")).to eq described_class
    end

    it "converts empty string to nil" do
      expect(described_class.demongoize("")).to eq nil
    end

    it "converts a string to a symbol" do
      expect(described_class.demongoize("asdf")).to eq :asdf
    end
  end
end