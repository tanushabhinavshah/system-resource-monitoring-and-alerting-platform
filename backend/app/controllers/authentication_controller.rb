class AuthenticationController < ApplicationController
  skip_before_action :authorize_request, only: [:register, :login]
  # 📝 Register a new user
  def register
    user = User.new(user_params)
    if user.save
      JwtService.encode(user_id: user.id)
      render json: { message: "User registered successfully!"}, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # 🔑 Login existing user
  def login
    user = User.find_by(email: params[:email])
    # '.authenticate' is provided by has_secure_password!
    if user&.authenticate(params[:password])
      token = JwtService.encode(user_id: user.id)
      render json: { token: token, message: "Login successful!" }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def logout
    # only send message; frontend will delete the token from local storage
    render json: { message: "Logged out successfully!"}, status: :ok
  end
  private

  def user_params
    params.permit(:name, :email, :password)
  end
end