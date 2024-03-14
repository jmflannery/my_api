ENV["RAILS_ENV"] ||= "test"
# Consider setting MT_NO_EXPECTATIONS to not add expectations to Object.
# ENV["MT_NO_EXPECTATIONS"] = "true"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :transaction

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Add more helper methods to be used by all tests here...
    include FactoryBot::Syntax::Methods
  end
end

class ApiIntegrationTestCase < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru')
  end

  register_spec_type(/\w+API$/, self)

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

  def parse_authorization_header
    auth_header = last_response.headers['Authorization']
    match = auth_header&.match(/\AToken (?<token>.+)\z/)
    return match&.named_captures&.dig('token')
  end
end