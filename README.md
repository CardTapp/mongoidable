# Mongoidable
An implementation of cancancan (https://github.com/CanCanCommunity/cancancan) which allows abilities to be statically or dynamically defined in one or many classes.

Using mongoidable you can define a mongoid document as having abilities and inheriting abilities from another document.

Example:

```
class User
  include Mongoid::Document
  include Mongoidable::Document

  belongs_to :parent, class_name: "Parent1", required: false

  inherits_abilities_from(:parent)

  define_abilities do |abilities, model|
    abilities.can :user_class_thing, User
    abilities.cannot :other_user_class_thing, User
  end
end

class Parent
  include Mongoid::Document
  include Mongoidable::Document

  define_abilities do |abilities, model|
    abilities.can :parent_class_thing, User
    abilities.cannot :other_parent_class_thing, User
  end
end
user = User.new
user.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :random_user_instance_thing, subject: User)
parent = Parent.new
parent.instance_abilities << Mongoidable::Ability.new(base_behavior: true, action: :random_parent_instance_thing, subject: User)

user.parent = parent

puts user.can?(:user_class_thing)
true
puts user.can?(:other_user_class_thing)
false
puts user.can?(:parent_class_thing)
true
puts user.can?(:other_parent_class_thing)
false
puts user.can?(:random_user_instance_thing)
true
puts user.can?(:random_parent__instance_thing)
true
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'mongoidable'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install mongoidable
```

## Configuration

It is possible to configure mongoidable to allow certain context in the ability definition blocks. To configure this context create a module that will provide the contexts and set config.context_module to the module in an initializer.

Example

```
module MongoidableContext
  def current_user
    UserInfo.current_user
  end
end

Mongoidable.configure do |config|
  config.context_module = MongoidableContext
end
```

## Extension
You may find in your implementation that you need additional functionality for the records that are saved as an instance ability. To do so, simply derive your new class from "Mongoidable::Ability" and specify it in the config initializer. `config.ability_class = "MyApplication::Ability"`
## Spec helpers

Mongoidable adds several spec hooks that can be used to setup default behaviors. To use these hooks add the symbol to the test description or context

Example
```
describe "that thing", :with_abilities do
  it "does not do thing", default_can_ability_with: false do

  end
end
```

Spec hooks available in all specs
* with_abilities: true - Uses abilities with no stubs in place
* with_abilities: {action: :subject, action2: :subject2} adds only these checks to the ability list
* :default_can_ability_with - Stubs the default value for a can? check Example `default_can_ability_with: true`
* :default_cannot_ability_with - Stubs the default value for a cannot? check Example`default_cannot_ability_with: false`
* :default_abilities - Stubs the default value for can? to true and cannot? to false

Spec hooks available to controllers
* :authorizes_controller - Stubs controller.authorize! to return true

Controller Authorization Test Helpers
Mongoidable includes a test helper for verifying that controller actions are authorized. In it's simplest form it will appear as follows
```
it { is_expected.to authorize(:action, subject).for(:index) }
```
The test helpers will stub out the controller action and any controller before_action hooks and verify only that the cancan controller authorization callback is ran. 

To include specific actions use `runs_actions`. These hooks will be ran prior to verifying the correct authorize calls.
```
it { is_expected.to authorize(:action, subject).for(:index).run_actions(:first_hook, :second_hook }
```
If the action requires special parameters such as an id or format. Include the params in the `for` arguments
```
it { is_expected.to authorize(:action, subject).for(:index, id: 1, format: :json).run_actions(:first_hook, :second_hook }
```