class User::Notification
  class MarkRelevantAsRead
    include Mandate

    initialize_with :user, :path

    def call
      User::Notification.pending_or_unread.
        where(
          user: user,
          path: path
        ).update_all(
          status: :read,
          read_at: Time.current
        )

      NotificationsChannel.broadcast_changed!(user)
    end
  end
end
