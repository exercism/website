class User::Notification::MarkBatchAsUnread
  include Mandate

  initialize_with :user, :uuids

  def call
    return if uuids.empty?

    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      ids = user.notifications.read.where(uuid: uuids).pluck(:id)

      return unless ids.present?

      User::Notification.where(id: ids).update_all(status: :unread, read_at: nil)
      NotificationsChannel.broadcast_changed!(user)
    end
  end
end
