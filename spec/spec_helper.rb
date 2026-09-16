require 'base64'
require 'bundler/setup'
require 'pry'
require 'nxt_support'
require 'nxt_support/rspec'
require 'active_record'
require 'active_support/testing/time_helpers'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Encryption.configure(
  primary_key: 'nxt-support-primary-key',
  deterministic_key: 'nxt-support-deterministic-key',
  key_derivation_salt: 'nxt-support-key-derivation-salt',
  hash_digest_class: OpenSSL::Digest::SHA256,
  support_sha1_for_non_deterministic_encryption: false
)

RSpec.configure do |config|
  config.include NxtSupport::RSpec::Encryption

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
end

Dir[File.join(Pathname.new(__FILE__).dirname, 'support', '**', '*.rb')].each { |f| require f }
