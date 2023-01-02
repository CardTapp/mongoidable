# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"
RSpec.describe "class_abilities", :with_abilities do
  after do
    Object.send(:remove_const, :User)
    load "dummy/app/models/user.rb"
  end

  it "validates when klass is a string, it constantizes to a document" do
    expect { User.inherits_abilities_from(String) }.to raise_error(ArgumentError)
  end

  it "validates when klass is a symbol, it constantizes to a document" do
    expect { User.inherits_abilities_from(:string) }.to raise_error(ArgumentError)
  end

  it "passes validation when klass is a Mongoid::Document" do
    expect { User.inherits_abilities_from(:parent1) }.not_to raise_error(ArgumentError)
  end

  it "defines inherits_abilities_from on document models" do
    expect(User).to respond_to(:inherits_abilities_from)
  end

  it "collects inherited ability tree" do
    expect(User.inherits_from[0][:name]).to eq :parent1
    expect(User.inherits_from[1][:name]).to eq :parent2
  end

  it "requires a sort order for many relations" do
    expect { User.inherits_abilities_from(:embedded_parents) }.to raise_error(ArgumentError)
  end

  it "does not allow sort order for singular relations" do
    expect { User.inherits_abilities_from(:parent1, order_by: :id) }.to raise_error(ArgumentError)
  end

  it "checks abilities for included modules" do
    model = Modules.new
    allow(model).to receive(:mongoidable_identity).and_return({})
    expect(model.current_ability.to_casl_list).to eq(
      [
          {
              action: [:do_included_stuff],
              subject: ["User"],
              has_block: false,
              source: nil,
              description: "translation missing: en.mongoidable.ability.description.do_included_stuff",
              type: :static
          },
          {
              action: [:do_own_stuff],
              subject: ["User"],
              has_block: false,
              source: nil,
              description: "translation missing: en.mongoidable.ability.description.do_own_stuff",
              type: :static
          },
          {
              action: [:do_other_own_stuff],
              subject: ["User"],
              inverted: true,
              has_block: false,
              source: nil,
              description: "translation missing: en.mongoidable.ability.description.do_other_own_stuff",
              type: :static
          }
      ]
    )
  end
end
