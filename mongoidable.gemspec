# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "mongoidable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "mongoidable"
  spec.version     = Mongoidable::VERSION
  spec.authors     = ["Jason Risch"]
  spec.email       = ["jason@cardtapp.com"]
  spec.homepage    = ""
  spec.summary     = "Summary of Mongoidable."
  spec.description = "Description of Mongoidable."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "active_model_serializers"
  spec.add_dependency "cancancan"
  spec.add_dependency "cancancan-mongoid"
  spec.add_dependency "cancancan_pub_sub"
  spec.add_dependency "devise"
  spec.add_dependency "memoist"
  spec.add_dependency "method_source"
  spec.add_dependency "mongoid", "~> 6.4.5"
  spec.add_dependency "ParseTree"
  spec.add_dependency "rails", "~> 5.2.4", ">= 5.2.4.3"
  spec.add_dependency "ruby2js"
  spec.add_dependency "ruby2ruby"
  spec.add_dependency "ruby_parser"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-i18n"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails"
  spec.add_development_dependency "rubocop-require_tools"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "rubocop-thread_safety"
end
