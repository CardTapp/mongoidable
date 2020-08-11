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
