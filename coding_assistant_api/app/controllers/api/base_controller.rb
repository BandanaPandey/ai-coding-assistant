class Api::BaseController < ApplicationController
  before_action :authenticate!
  attr_reader :current_user

  private

  def authenticate!
    puts("Authenticating user...")
    puts("Request headers: #{request.headers["Authorization"]}")
    token = request.headers["Authorization"]&.split(" ")&.last

    payload = Auth::JwtService.decode(token)
    puts("Decoded JWT payload: #{payload}")

    @current_user = User.find(payload["user_id"])
  rescue
    render json: { error: "Unauthorized" }, status: 401
  end
end