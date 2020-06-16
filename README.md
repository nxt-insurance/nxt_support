[![CircleCI](https://circleci.com/gh/nxt-insurance/nxt_support.svg?style=svg)](https://circleci.com/gh/nxt-insurance/nxt_support)

# NxtSupport

This is a collection of mixins, helpers and classes that cover several aspects of a ruby on rails application, such as models, controllers and job processing. At [Getsafe](https://hellogetsafe.com), we run multiple Ruby on Rails apps as part of our insurance infrastructure and we found that we wrote quite some shared helpers that are duplicated among applications and serve a generic purpose that we could share in this gem. Look at it as our version of ActiveSupport (which is amazing! ❤️), droping in the pieces we sometimes miss in the beautiful puzzle of Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nxt_support'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nxt_support

## Usage

Here's an overview all the supporting features.

### NxtSupport/Models

Enjoy support for your models.

#### NxtSupport::Email

This class collects useful tools around working with email addresses. Use `NxtSupport::Email::REGEXP` to match email address strings. See the sources for a list of criteria it validates.

#### NxtSupport::IndifferentlyAccessibleJsonAttrs

This mixin provides the `indifferently_accessible_json_attrs` class method which serializes and deserializes JSON database columns with `ActiveSupport::HashWithIndifferentAccess` instead of `Hash`.

```ruby
class MyModel < ApplicationRecord
  include IndifferentlyAccessibleJsonAttrs
  
  indifferently_accessible_json_attrs :data
end
```

#### NxtSupport::SafelyFindOrCreateable

The `NxtSupport::Models::SafelyFindOrCreateable` concern is aimed at ActiveRecord models with a uniqueness database constraint. If you use `find_or_create_by` from ActiveRecord, it can happen that the `find_by` call returns `nil` (because no record for the given conditions exists), but in the small timeframe between the `find_by` and the `create` call, another thread inserts a record, so that the `create` call raises an error.

The `safely_find_or_create_by` method provided by this concern catches such an error and performs `find_by` another time. It also offers a bang variant.

```ruby
class Book < ApplicationRecord
	include NxtSupport::SafelyFindOrCreateable
end

Book.safely_find_or_create_by!(market: 'de', title: 'Moche!')
```

### NxtSupport/Serializers

Enjoy mixins for your serializers.

#### NxtSupport::HasTimeAttributes

This mixin provides your serializer classes with a `attribute_as_iso8601` and a `attributes_as_iso8601` method. They behave almost the same as the `attribute` method of [active_model_serializers](https://github.com/rails-api/active_model_serializers) (in fact they call it behind the scenes), but they convert the values of the given attributes to an ISO8601 string. This is useful for `Date`, `Time` or `ActiveSupport::Duration` values.

```ruby
class MySerializer < ActiveModel::Serializer
  include NxtSupport::HasTimeAttributes
  
  attributes_as_iso8601 :created_at, :updated_at
end
```

### NxtSupport/Util

Enjoy some useful utilities

#### NxtSupport::EnumHash

`NxtSupport::EnumHash` is a simple hash with indifferent access to organize a collection of enums. 
Keys will be normalized to be underscore and downcase and access with [] is raising a `KeyError` in case there is 
no value for the key.

```ruby
class Book
  STATES = NxtSupport::EnumHash['draft', 'revised', 'Published', 'in weird State']
end

Book::STATES[:draft] # 'draft'
Book::STATES['revised'] # 'revised'
Book::STATES['published'] # 'Published'
Book::STATES['Published'] # KeyError
Book::STATES['in_weird_state'] # 'in weird State'

```

#### NxtSupport::HashTranslator

`NxtSupport::HashTranslator` is a module that allows you to manipulate keys and values of original hash through tuple hash. 
Tuple hash is a hash where `key` - represent's the key of original hash, and `value` - represents the key of result hash.
Use `#translate_hash` method to get the result hash.

```ruby
class TestClass
  include NxtSupport::HashTranslator
end

TestClass.translate_hash(firstname: 'John', firstname: :first_name)
=> { 'first_name' => 'John' }
```
The `value` also could be a `Hash` where key represents the new key in result hash and value must be a lambda or Proc
that would be used to process value from origin hash. If the tuple hash contains more than 1 key-value paris or value in key value pair 
is not a callable block `InvalidTranslationArgument` error would be raised.

```ruby
class TestClass
  include NxtSupport::HashTranslator
end

hash = { firstname: 'John', phonenumber: '11-22-33-445' }
tuple = {
          firstname: :first_name,
          phonenumber: {
            phone_number: ->(number) { number.to_s.prepend('+49-') }
          }
        }

TestClass.translate_hash(hash, tuple)
=> { 'first_name' => 'John', 'phone_number' => '+49-11-22-33-445' }

hash = { firstname: 'John', phonenumber: '11-22-33-445' }
tuple = {
          firstname: :first_name,
          phonenumber: {
            phone_number: :some_symbol
          }
        }

TestClass.translate_hash(hash, tuple)
=> InvalidTranslationArgument (some_symbol must be a callable block!)

hash = { firstname: 'John', phonenumber: '11-22-33-445' }
tuple = {
          firstname: :first_name,
          phonenumber: {
            phone_number: ->(number) { number.to_s.prepend('+49-') },
            unused_key: :some_symbol
          }
        }

TestClass.translate_hash(hash, tuple)
=> InvalidTranslationArgument ({:phone_number=>#<Proc:0x00007ff503175b88 (lambda), :unused_key=>:some_symbol} must contain only 1 key-value pair!)
```

Or an `Array`.

```ruby
class TestClass
  include NxtSupport::HashTranslator
end

hash = { firstname: 'John', lastname: 'Doe' }
tuple = { firstname: :first_name, lastname: [:last_name, :maiden_name] }

TestClass.translate_hash(hash, tuple)
=> { 'first_name' => 'John', 'last_name' => 'Doe', 'maiden_name' => 'Doe' }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nxt_insurance/nxt_support.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
