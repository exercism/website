class User::Notification
  class MarkRelevantAsRead
    include Mandate

    initialize_with :user, :path

    def call
      pending_or_unread = User::Notification.pending_or_unread.where(user: user, path: path)

      return if pending_or_unread.empty?

      pending_or_unread.update_all(status: :read, read_at: Time.current)

      NotificationsChannel.broadcast_changed!(user)
    end
  end
end
