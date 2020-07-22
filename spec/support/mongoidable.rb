# frozen_string_literal: true

module MongoidableContext
  def current_user
    nil
  end
end

Mongoidable.context_module = MongoidableContext