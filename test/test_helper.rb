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

  def find_or_create_token user, key = nil
    Token.find_or_create_by_key key: key, user: user, ip_address: '127.0.0.1'
  end

  def sign_in user, key = nil
    @token = find_or_create_token user, key
    rack_test_session.set_cookie "api_key=#{@token.key}"
  end

  def sign_in_with_header user, key = nil
    @token = find_or_create_token user, key
    header 'Authorization', "Bearer #{@token.key}"
  end

  def parse_authorization_header(rack_headers)
    auth_header = rack_headers['Authorization']
    match = auth_header&.match(/\AToken (?<token>.+)\z/)
    return match&.named_captures&.dig('token')
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
