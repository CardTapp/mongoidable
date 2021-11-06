# frozen_string_literal: true

require "database_cleaner/mongoid"

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :deletion

    DatabaseCleaner.clean
  end

  config.around do |example|
    DatabaseCleaner.clean

    example.run
  end
end
