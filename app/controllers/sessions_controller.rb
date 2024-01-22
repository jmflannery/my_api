class SessionsController < ApplicationController
  before_action :find_user
  skip_before_action :authenticate_token!, only: %i[create]

  def create
    if @user.authenticate(params[:password])
      sign_in
      render json: @user, status: :created
    else
      head :unauthorized
    end
  end

  def destroy
  end

  private

  def find_user
    @user = User.find_by! email: params[:email]
  end

  def sign_in
    token = Token.find_or_create_by_key(key: @auth_key, user: @user, ip_address: request.remote_ip)
    cookies[:api_key] = {
      value: token.key,
      expires: 1.year,
      httponly: true,
      secure: true,
    }
    response.headers['Authorization'] = "Token #{token.key}"
  end
end
