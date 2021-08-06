class User::Notification
  class MarkAllAsRead
    include Mandate

    initialize_with :user

    def call
      num_changed = user.notifications.pending_or_unread.
        update_all(status: :read, read_at: Time.current)

      NotificationsChannel.broadcast_changed!(user) if num_changed.positive?
    end
  end
end
