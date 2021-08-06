class User::Notification
  class MarkRelevantAsRead
    include Mandate

    initialize_with :user, :path

    def call
      num_changed = user.notifications.pending_or_unread.where(path: path).
        update_all(status: :read, read_at: Time.current)

      NotificationsChannel.broadcast_changed!(user) if num_changed.positive?
    end
  end
end
