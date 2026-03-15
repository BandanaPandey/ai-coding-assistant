class Api::AuthController < ApplicationController
  def login
    user = User.find_by(api_key: params[:api_key])

    if user
      token = Auth::JwtService.encode(user_id: user.id)

      render json: { token: token }
    else
      render json: { error: "Invalid API key" }, status: 401
    end
  end
end