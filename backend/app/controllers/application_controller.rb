class ApplicationController < ActionController::API
  # This runs before EVERY action in EVERY controller
  before_action :authorize_request
  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header # Get token from "Bearer <token>"
    begin
      # Decode using the same Secret Key we used to sign the token
      @decoded = JWT.decode(header, Rails.application.credentials.secret_key_base)[0]
      @current_user = User.find(@decoded['user_id'])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: "Invalid or missing token" }, status: :unauthorized
    end
  end
end
