class RootController < ApplicationController
  skip_before_action :authenticate_token!

  def show
    profile = User.first&.profile || {}
    render json: profile
  end
end
