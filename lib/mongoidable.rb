# frozen_string_literal: true

require "mongoid"
require "cancan"
require "memoist"

require "mongoidable/class_abilities"
require "mongoidable/current_ability"
require "mongoidable/document_extensions"
require "mongoidable/engine"
require "mongoidable/instance_abilities"
require "mongoidable/parent_abilities"

module Mongoidable
  extend ActiveSupport::Concern
  mattr_accessor :context_module

  included do
    include Mongoidable::ClassAbilities
    include Mongoidable::CurrentAbility
    include Mongoidable::DocumentExtensions
    include Mongoidable::InstanceAbilities
    include Mongoidable::ParentAbilities
  end
end
