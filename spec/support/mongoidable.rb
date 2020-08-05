# frozen_string_literal: true

module MongoidableContext
  def current_user
    nil
  end
end

Mongoidable.configure do |config|
  config.context_module = MongoidableContext
end
