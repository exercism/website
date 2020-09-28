class NotificationsChannel < ApplicationCable::Channel
  def self.broadcast_changed(user, count: user.notifications.unread.count)
    NotificationsChannel.broadcast_to(user, {
                                        type: "notifications.changed",
                                        payload: { count: count }
                                      })
  end

  def subscribed
    stream_for current_user
  end

  def unsubscribed; end
end
