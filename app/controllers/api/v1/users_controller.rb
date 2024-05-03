# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController
      # Skip authentication for certain actions
      skip_before_action :doorkeeper_authorize!, only: %i[create login logout verify_otp_and_login forgot_password reset_password]


      # show all user
      def index
        @user = User.all
        render json: { user: @user, message: 'This is list of all user' }, status: :ok
      end

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
        if request.headers['Authorization'].present?
          token = request.headers['Authorization'].split(' ').last
          current_token = Doorkeeper::AccessToken.find_by(token: token)
          if current_token
            render_logout_response(current_token.destroy)
          else
            render_unauthorized_response('Invalid access token')
          end
        else
          render_unauthorized_response('Access token not provided')
        end
      end

      # User login via email and password and Send OTP for verification
      def login
        user = User.find_by(email: params[:user][:email])
      
        if user&.valid_password?(params[:user][:password])
          # Generate OTP and send to user's email
          otp = generate_otp
          send_otp_email(user, otp)
          render json: { message: 'OTP sent to your email. Please enter it.', email: user.email }, status: :ok
        else
          render_unauthorized_response('Invalid email or password')
        end
      end

      # Verify OTP and login 
      def verify_otp_and_login
        email = params[:user][:email]
        otp = params[:user][:otp]
      
        user = User.find_by(email: email)
      
        if user && user.otp == otp
          user.update(otp: nil) # Clear OTP
          client_app = Doorkeeper::Application.find_by(uid: params[:client_id])
          access_token = create_access_token(user, client_app)
          render_login_response(user, access_token, 'Login successful')
        else
          render_unauthorized_response('Invalid OTP')
        end
      end


      def forgot_password
        user = User.find_by(email: params[:email])
    
        if user
          otp = generate_otp
          user.update(otp: otp)
          UserMailer.with(user: user, otp: otp).reset_password_email.deliver_now
          render json: { message: 'OTP sent to your email. Please enter it to reset your password.', email: user.email }, status: :ok
        else
          render_unauthorized_response('Invalid email address')
        end
      end


      def reset_password
        
        email = params[:user][:email]
        otp = params[:user][:otp]
        password = params[:password]
      
        user = User.find_by(email: email)
      
        if user && (user.otp.nil? || user.otp == otp)
          user.update(password: password, otp: nil)
          render json: { message: 'Password reset successful' }, status: :ok
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
      def render_login_response(user, access_token, message)
        render json: {
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            created_at: access_token.created_at.to_time.to_i,
            access_token: access_token.token,
          },
          message: message
        }, status: :ok
      end

      # Render user response
      def user_response(user, access_token)
        {
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            created_at: access_token.created_at.to_time.to_i,
            access_token: access_token.token
          }
        }
      end

      # Send OTP to user's email
      def send_otp_email(user, otp)
        user.update(otp: otp)
        UserMailer.with(user: user, otp: otp).otp_email.deliver_now
      end

      # Generate OTP
      def generate_otp
        rand(1000..9999).to_s.rjust(4, '0')
      end
    end
  end
end
