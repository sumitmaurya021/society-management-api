module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :doorkeeper_authorize!
      before_action :authorize_admin!, only: [:create]
      before_action :set_notification, only: [:show, :update, :destroy]

      def index
        @notifications = Notification.all
        render json: @notifications
      end

      def show
        render json: { notification: @notification, message: 'Notification retrieved successfully' }, status: :ok
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

      def update
        if @notification.update(notification_params)
          render json: { message: 'Notification updated successfully' }, status: :ok
        else
          render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @notification.destroy
        render json: { message: 'Notification deleted successfully' }, status: :ok
      end

      private

      def set_notification
        @notification = Notification.find(params[:id])
      end

      def notification_params
        params.require(:notification).permit(:title, :message, :user_id)
      end

      def authorize_admin!
        render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user && current_user.role == "admin"
      end

      def send_notification_to_all_users(notification)
        ActionCable.server.broadcast("NotificationChannel", {
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
