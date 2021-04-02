# frozen_string_literal: true

module Mongoidable
  class Engine < ::Rails::Engine
    config.autoload_paths += %W[#{config.root}/app/controllers]
    isolate_namespace Mongoidable
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
