class ApplicationController < ActionController::API
  before_action :check_authentication_cookie

  private

  def check_authentication_cookie
    @auth_key = cookies[:api_key]
  end
end
