module Mongoidable
  class AbilitiesUpdater
    extend Memoist
    attr_reader :model, :abilities, :replace

    def initialize(model, abilities, replace: false)
      @model = model
      @abilities = abilities
      @replace = ActiveModel::Type::Boolean.new.cast(replace)
    end

    def call
      model.instance_abilities.clear if replace_abilities?
      abilities.map { |ability_params| model.instance_abilities.update_ability(**ability_params) }
    end

    def model_type
      model.class.name.downcase
    end

    def replace_abilities?
      replace
    end
  end
end