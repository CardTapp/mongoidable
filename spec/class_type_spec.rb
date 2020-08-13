# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::ClassType do
  describe "mongoize" do
    it "does not change a string representation of a class" do
      expect(Mongoidable::ClassType.mongoize("Mongoidable::ClassType")).to eq "Mongoidable::ClassType"
    end

    it "converts a class to a string" do
      expect(Mongoidable::ClassType.mongoize(Mongoidable::ClassType)).to eq "Mongoidable::ClassType"
    end

    it "converts nil to empty string" do
      expect(Mongoidable::ClassType.mongoize(nil)).to eq ""
    end

    it "converts a symbol to a string" do
      expect(Mongoidable::ClassType.mongoize(:asdf)).to eq "asdf"
    end
  end

  describe "demongoize" do
    it "converts a string to a class" do
      expect(Mongoidable::ClassType.demongoize("Mongoidable::ClassType")).to eq Mongoidable::ClassType
    end

    it "converts empty string to nil" do
      expect(Mongoidable::ClassType.demongoize("")).to eq nil
    end

    it "converts a string to a symbol" do
      expect(Mongoidable::ClassType.demongoize("asdf")).to eq :asdf
    end
  end
end