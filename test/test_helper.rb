ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "minitest/pride"
require "rack/test"
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :transaction

class Minitest::Test
  include FactoryBot::Syntax::Methods

  def before_setup
    super
    DatabaseCleaner.clean
    DatabaseCleaner.start
  end

  def sign_in user, key = nil
    @token = Token.find_or_create_by_key key: key, user: user, ip_address: '1.2.3.4'
    rack_test_session.set_cookie "api_key=#{@token.key}"
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
