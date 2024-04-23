module Api
  module V1
    class UsersController < ApplicationController
      # Skip authentication for certain actions
      skip_before_action :doorkeeper_authorize!, only: %i[create login verify_and_generate_token]

      # User registration
      def create
        user = User.new(user_params)

        # Find the client application
        client_app = Doorkeeper::Application.find_by(uid: params[:client_id])

        # Return error if client app is invalid
        return render(json: { error: 'Invalid client ID' }, status: 403) unless client_app

        if user.save
          # Create access token for the user
          access_token = create_access_token(user, client_app)

          # Render successful response
          render(json: user_response(user, access_token))
        else
          # Render error response
          render(json: { error: user.errors.full_messages }, status: 422)
        end
      end

      # User logout
      def logout
        if params[:access_token].present?
          current_token = Doorkeeper::AccessToken.find_by(token: params[:access_token])
          if current_token
            render_logout_response(current_token.destroy)
          else
            render_unauthorized_response('Invalid access token')
          end
        else
          render_unauthorized_response('Access token not provided')
        end
      end

      def login
        @user = User.find_by(email: params[:user][:email])
      
        if @user&.valid_password?(params[:user][:password])
          binding.pry
          if @user.generate_otp && @user.save # Ensure OTP is generated and saved
            if @user.send_otp
              render json: { message: 'OTP sent to your email. Please enter OTP to log in.' }, status: :ok
            else
              render_unauthorized_response('Failed to send OTP')
            end
          else
            render_unauthorized_response('Failed to generate or save OTP')
          end
        else
          render_unauthorized_response('Invalid email or password')
        end
      end

      def verify_and_generate_token
        @user = User.find_by(email: params[:user][:email])
      
        if @user.present? && @user.verify_otp(params[:user][:otp])
          client_app = Doorkeeper::Application.find_by(uid: params[:client_id])
          access_token = create_access_token(@user, client_app)
          render_login_response(access_token)
        else
          render_unauthorized_response('Invalid OTP')
        end
      end

      private

      # Strong parameters for user
      def user_params
        params.require(:user).permit(:email, :password, :name, :role, :otp)
      end

      # Find current user
      def current_user
        @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
      end

      # Generate a unique refresh token
      def generate_refresh_token
        loop do
          token = SecureRandom.hex(32)
          break token unless Doorkeeper::AccessToken.exists?(refresh_token: token)
        end
      end

      # Create access token
      def create_access_token(user, client_app)
        Doorkeeper::AccessToken.create!(
          resource_owner_id: user.id,
          application_id: client_app.id,
          refresh_token: generate_refresh_token,
          expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
          scopes: ''
        )
      end

      # Render logout response
      def render_logout_response(destroyed)
        if destroyed
          render json: { message: 'Logout successful' }, status: :ok
        else
          render json: { error: 'Failed to destroy access token' }, status: :unprocessable_entity
        end
      end

      # Render unauthorized response
      def render_unauthorized_response(message)
        render json: { error: message }, status: :unauthorized
      end

      # Render login response
      def render_login_response(access_token)
        render json: { user: @user, access_token: access_token.token, message: 'Login successful' }, status: :ok
      end

      # Prepare user response
      def user_response(user, access_token)
        {
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            created_at: access_token.created_at.to_time.to_i,
            access_token: access_token.token,
          }
        }
      end
    end
  end
end
