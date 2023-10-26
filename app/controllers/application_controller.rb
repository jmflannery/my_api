class ApplicationController < ActionController::API
  include ActionController::Cookies

  attr_reader :current_user

  before_action :check_authentication_cookie, :authenticate_token!

  private

  def check_authentication_cookie
    @auth_key = cookies[:api_key]
    @token = Token.find_by key: @auth_key
    @current_user = @token&.user
  end

  def authenticate_token!
    head :unauthorized unless current_user
  end
end
