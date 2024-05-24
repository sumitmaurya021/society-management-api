module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :doorkeeper_authorize!
      before_action :authorize_admin!, only: [:create]

      def index
        @notifications = Notification.all
        render json: @notifications
      end

      def show
        @notification = current_user.notifications.find(params[:id])
        render json: @notification
      end

      def create
        notification = Notification.new(notification_params)
        if notification.save
          send_notification_to_all_users(notification)
          render json: { message: 'Notification created successfully' }, status: :ok
        else
          render json: { errors: notification.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def notification_params
        params.require(:notification).permit(:title, :message, :user_id)
      end

      def authorize_admin!
        render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user && current_user.role == "admin"
      end

      def send_notification_to_all_users(notification)
        User.find_each do |user|
          user.notifications.create(title: notification.title, message: notification.message)
          ActionCable.server.broadcast("NotificationChannel",   {
            id: notification.id,
            title: notification.title,
            message: notification.message,
            read: notification.read,
            created_at: notification.created_at.strftime("%Y-%m-%d %H:%M:%S")
          })
        end
      end
    end
  end
end
