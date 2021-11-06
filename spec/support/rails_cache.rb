# frozen_string_literal: true

require "database_cleaner/mongoid"

RSpec.configure do |config|
  config.before do
    Rails.cache.clear
  end
end
