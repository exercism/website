class User::Notification::MarkAllAsRead
  include Mandate

  initialize_with :user

  def call
    num_changed = 0
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      num_changed = user.notifications.pending_or_unread.
        update_all(status: :read, read_at: Time.current)
    end
    NotificationsChannel.broadcast_changed!(user) if num_changed.positive?
  end
end
