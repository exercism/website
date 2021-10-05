class NotificationsChannel < ApplicationCable::Channel
  def self.broadcast_changed!(user)
    NotificationsChannel.broadcast_to(user, { type: "notifications.changed" })
  end

  def self.broadcast_pending!(user, notification)
    NotificationsChannel.broadcast_to(user, {
      type: "notifications.pending",
      notification_id: notification.uuid,
      notification_path: notification.path
    })
  end

  def subscribed
    stream_for current_user
  end

  def unsubscribed; end
end
