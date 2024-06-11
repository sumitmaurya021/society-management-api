# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController
      # Skip authentication for certain actions
      skip_before_action :doorkeeper_authorize!, only: %i[index create login logout verify_otp_and_login forgot_password reset_password login_by_customer reset_password_for_customer forgot_password_for_customer] 


      # show only customer user list
      def index
        if current_user.role == 'admin'
          @users = User.where(role: 'customer').map do |user|
            {
              id: user.id,
              email: user.email,
              name: user.name,
              password: user.password,
              created_at: user.created_at,
              updated_at: user.updated_at,
              otp: user.otp,
              mobile_number: user.mobile_number,
              block: Block.find(user.block_id).block_name,
              floor: Floor.find(user.floor_id).floor_number,
              room: Room.find(user.room_id).room_number,
              floor_id: user.floor_id,
              room_number: user.room_number,
              owner_or_renter: user.owner_or_renter,
              role: user.role,
              room_id: user.room_id,
              status: user.status,
              gender: user.gender
            }
          end
          render json: { users: @users, message: 'This is list of all users' }, status: :ok
        else
          render json: { error: 'You are not authorized to access this resource' }, status: :unauthorized
        end
      end
      
      def update
        if @user.update(user_params)
          render json: { message: 'User updated successfully' }, status: :ok
        else
          render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
        end
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
        # User.skip_callback(:validation, :before, :assign_block_floor_and_room)
        user = User.find_by(email: params[:user][:email])
      
        if user&.valid_password?(params[:user][:password])
          # Generate OTP and send to user's email
          otp = generate_otp
          send_otp_email(user, otp)
          render json: { message: 'OTP sent to your email. Please enter it.', email: user.email }, status: :ok
          # User.set_callback(:validation, :before, :assign_block_floor_and_room)
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

      def forgot_password_for_customer
        user = User.find_by(email: params[:email])
        if user
          otp = generate_otp
          user.update(otp: otp)
          UserMailer.with(user: user, otp: otp).reset_password_email_for_customer.deliver_now
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

      def reset_password_for_customer
        block_name = params[:block_name]
        room_number = params[:user][:room_number]
        otp = params[:user][:otp]
        password = params[:password]

        block = Block.find_by(name: block_name)
        user = User.find_by(block_id: block.id, room_number: room_number)

        if user && (user.otp.nil? || user.otp == otp)
          user.update(password: password, otp: nil)
          render json: { message: 'Password reset successful' }, status: :ok
        else
          render_unauthorized_response('Invalid OTP')
        end
      end
      

      def login_by_customer
        block_name = params[:user][:block_name]
        room_number = params[:user][:room_number]
        password = params[:user][:password]
      
        # Find block by name
        block = Block.find_by(block_name: block_name)
        return render_unauthorized_response('Invalid block name') unless block
        
        # Find user by block and room number
        user = User.find_by(block_id: block.id, room_number: room_number)
      
        if user
          if user.valid_password?(password)
            # Generate access token
            client_app = Doorkeeper::Application.find_by(uid: params[:client_id])
            access_token = create_access_token(user, client_app)
            
            # Render successful response
            render_login_response(user, access_token, 'Login successful')
          else
            puts "Invalid password"
            render_unauthorized_response('Invalid password')
          end
        else
          puts "User not found"
          render_unauthorized_response('Invalid block, room number, or password')
        end
      end

      # Accept user
      def accept_user
        user = User.find_by(id: params[:id])
        return render_unauthorized_response('User not found') unless user
        return render_unauthorized_response('User is already accepted') if user.status == 'accepted'

        User.skip_callback(:validation, :before, :assign_block_floor_and_room)

        user.update!(status: 'accepted')
        UserMailer.accept_user_email(user).deliver_now
        render json: { message: 'User accepted successfully', user: user }, status: :ok

        User.set_callback(:validation, :before, :assign_block_floor_and_room)

      end

      # Reject user
      def reject_user
        user = User.find_by(id: params[:id])
        return render_unauthorized_response('User not found') unless user
        return render_unauthorized_response('User is already rejected') if user.status == 'rejected'

        User.skip_callback(:validation, :before, :assign_block_floor_and_room)

        user.update(status: 'rejected')
        UserMailer.reject_user_email(user).deliver_now
        render json: { message: 'User rejected successfully', user: user }, status: :ok

        User.set_callback(:validation, :before, :assign_block_floor_and_room)
        
      end

      def update
        @user = User.find_by(id: params[:id])
        if @user.update(user_params)
          render json: { message: 'User updated successfully' }, status: :ok
        else
          render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

  
      
      private

      # Strong parameters for user
      def user_params
        if params[:user][:role] == 'admin'
          params.require(:user).permit(:email, :password, :name, :role, :otp)
        else
          params.require(:user).permit(:name, :email, :password, :otp, :mobile_number, :block_name, :floor_number, :room_number, :owner_or_renter, :gender)          
        end
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
        # block_name = Block.find(user.block_id).name
        render json: {
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            mobile_number: user.mobile_number,
            owner_or_renter: user.owner_or_renter,
            room_id: user.room_id,
            block_id: user.block_id,
            block_name: user.block.block_name,
            floor_number: user.floor.floor_number,
            floor_id: user.floor_id,
            room_number: user.room_number,
            status: user.status,
            gender: user.gender,
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
