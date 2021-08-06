class User::Notification
  class MarkBatchAsRead
    include Mandate

    initialize_with :user, :uuids

    def call
      return if uuids.blank?

      num_changed = user.notifications.pending_or_unread.where(uuid: uuids).
        update_all(status: :read, read_at: Time.current)

      NotificationsChannel.broadcast_changed!(user) if num_changed.positive?
    end
  end
end
