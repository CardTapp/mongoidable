# frozen_string_literal: true

# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
begin
  Rails.application.initialize!
rescue StandardError => e
  e.to_s
end
