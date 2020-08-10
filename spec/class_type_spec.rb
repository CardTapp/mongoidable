# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mongoidable::ClassType do
  describe "mongoize" do
    it "raises if the string is not a class type" do
      expect { Mongoidable::ClassType.mongoize("asdf") }.to raise_error(ArgumentError)
    end

    it "does not change a string representation of a class" do
      expect(Mongoidable::ClassType.mongoize("Mongoidable::ClassType")).to eq "Mongoidable::ClassType"
    end

    it "converts a class to a string" do
      expect(Mongoidable::ClassType.mongoize(Mongoidable::ClassType)).to eq "Mongoidable::ClassType"
    end

    it "converts nil to empty string" do
      expect(Mongoidable::ClassType.mongoize(nil)).to eq ""
    end
  end

  describe "demongoize" do
    it "converts a string to a class" do
      expect(Mongoidable::ClassType.demongoize("Mongoidable::ClassType")).to eq Mongoidable::ClassType
    end

    it "converts empty string to nil" do
      expect(Mongoidable::ClassType.demongoize("")).to eq nil
    end
  end
end