# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe "provied ability", :with_abilities do
  describe "one to one relationship" do
    describe "modifying provider abilities" do
      describe "ability added to provider" do
        it "adds the ability to providee" do
          provider = ProvidingParent.create
          providee = User.create(provider: provider)

          expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
          expect(providee.current_ability).to be_cannot(:provided_action, :provided_subject)

          provider.user_abilities.build(base_behavior: true, action: :provided_action, subject: :provided_subject)

          expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
          expect(providee.current_ability).to be_can(:provided_action, :provided_subject)
        end
      end

      describe "ability removed from provider" do
        it "removes the ability from providee" do
          provider = ProvidingParent.new
          providee = User.new(provider: provider)
          provider.user_abilities.build(base_behavior: true, action: :provided_action, subject: :provided_subject)

          expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
          expect(providee.current_ability).to be_can(:provided_action, :provided_subject)

          provider.user_abilities.build(base_behavior: false, action: :provided_action, subject: :provided_subject)

          providee.renew_abilities
          expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
          expect(providee.current_ability).to be_cannot(:provided_action, :provided_subject)
        end
      end
    end

    describe "modifying providee" do
      describe "setting a nil provider to a value" do
        it "adds the ability to providee" do
          provider = ProvidingParent.create
          providee = User.create

          expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
          expect(providee.current_ability).to be_cannot(:provided_action, :provided_subject)

          provider.user_abilities.build(base_behavior: true, action: :provided_action, subject: :provided_subject)
          providee.provider = provider
          providee.save
          provider.save
          providee.renew_abilities
          expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
          expect(providee.current_ability).to be_can(:provided_action, :provided_subject)
        end
      end

      describe "setting a provider to a nil" do
        it "removes the ability from the providee" do
          providee = User.new
          provider = ProvidingParent.new(providee: providee)
          provider.user_abilities.build(base_behavior: true, action: :provided_action, subject: :provided_subject)

          expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
          expect(providee.current_ability).to be_can(:provided_action, :provided_subject)

          provider.providee = nil
          provider.save

          expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
          expect(providee.reload.current_ability).to be_cannot(:provided_action, :provided_subject)
        end
      end
    end

    describe "modifying a provider" do
      describe "setting a nil providee to a value" do
        it "adds the ability to new providee" do
          provider = ProvidingParent.new
          providee = User.new

          expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
          expect(providee.current_ability).to be_cannot(:provided_action, :provided_subject)

          provider.user_abilities.build(base_behavior: true, action: :provided_action, subject: :provided_subject)
          provider.providee = providee
          provider.save

          expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
          expect(providee.current_ability).to be_can(:provided_action, :provided_subject)
        end
      end

      describe "setting a providee to nil" do
        it "removes the ability from the providee" do
          # Invalid test? provider.prividee = nil gets reset by mongo to the original value
        end
      end
    end

    describe "destroying a provider" do
      it "removes the ability from the providee" do
        providee = User.create
        provider = ProvidingParent.create(providee: providee)
        provider.user_abilities.build(base_behavior: true, action: :provided_action, subject: :provided_subject)

        expect(provider.current_ability).to be_cannot(:provided_action, :provided_subject)
        expect(providee.current_ability).to be_can(:provided_action, :provided_subject)

        provider.destroy

        providee.reload.renew_abilities
        expect(providee.current_ability).to be_cannot(:provided_action, :provided_subject)
      end
    end
  end
end