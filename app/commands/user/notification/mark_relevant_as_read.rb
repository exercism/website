class User::Notification::MarkRelevantAsRead
  include Mandate

  initialize_with :user, :path

  def call
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      num_changed = user.notifications.pending_or_unread.where(path:).
        update_all(status: :read, read_at: Time.current)

      NotificationsChannel.broadcast_changed!(user) if num_changed.positive?
    end
  end
end
