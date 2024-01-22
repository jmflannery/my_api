class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::HttpAuthentication::Token::ControllerMethods

  attr_reader :current_user

  before_action :check_authorization_cookie, :check_authorization_header, :authenticate_token!

  private

  def check_authorization_cookie
    return if current_user

    @auth_key = cookies[:api_key]
    @token = Token.find_by key: @auth_key
    @current_user = @token&.user
  end

  def check_authorization_header
    return if current_user

    authenticate_with_http_token do |key|
      @auth_key = key
      @token = Token.find_by key: @auth_key
      @current_user = @token&.user
    end
  end

  def authenticate_token!
    head :unauthorized unless current_user
  end
end
