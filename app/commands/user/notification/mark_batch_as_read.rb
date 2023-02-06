class User::Notification::MarkBatchAsRead
  include Mandate

  initialize_with :user, :uuids

  def call
    return if uuids.blank?

    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      num_changed = user.notifications.pending_or_unread.where(uuid: uuids).
        update_all(status: :read, read_at: Time.current)

      NotificationsChannel.broadcast_changed!(user) if num_changed.positive?
    end
  end
end
