class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "NotificationChannel"
    Rails.logger.info "Client subscribed to NotificationChannel"
  end

  def unsubscribed
    stop_all_streams
    Rails.logger.info "Client unsubscribed from NotificationChannel"
  end
end
