class User::Notification::MarkBatchAsUnread
  include Mandate

  initialize_with :user, :uuids

  def call
    return if uuids.empty?

    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      num_changed = user.notifications.read.where(uuid: uuids).
        update_all(status: :unread, read_at: nil)

      NotificationsChannel.broadcast_changed!(user) if num_changed.positive?
    end
  end
end
