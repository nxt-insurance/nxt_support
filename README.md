![](https://github.com/nxt-insurance/nxt_support/workflows/ruby/badge.svg)

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

### NxtSupport::Models

Enjoy support for your models.

#### NxtSupport::Models::SafelyFindOrCreateable

The `NxtSupport::Models::SafelyFindOrCreateable` concern is aimed at ActiveRecord models with a uniqueness database constraint. If you use `find_or_create_by` from ActiveRecord, it can happen that the `find_by` call returns `nil` (because no record for the given conditions exists), but in the small timeframe between the `find_by` and the `create` call, another thread inserts a record, so that the `create` call raises an error.

The `safely_find_or_create_by` method provided by this concern catches such an error and performs `find_by` another time. It also offers a bang variant.

```ruby
class Book < ApplicationRecord
	include NxtSupport::Models::SafelyFindOrCreateable
end

Book.safely_find_or_create_by!(market: 'de', title: 'Moche!')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nxt_insurance/nxt_support.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
