class User::Notification::MarkBatchAsRead
  include Mandate

  initialize_with :user, :uuids

  def call
    return if uuids.blank?

    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      ids = user.notifications.pending_or_unread.where(uuid: uuids).pluck(:id)

      return unless ids.present?

      User::Notification.where(id: ids).update_all(status: :read, read_at: Time.current)
      NotificationsChannel.broadcast_changed!(user)
    end
  end
end
