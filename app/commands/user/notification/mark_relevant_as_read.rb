class User::Notification::MarkRelevantAsRead
  include Mandate

  initialize_with :user, :path

  def call
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      ids = user.notifications.pending_or_unread.where(path:).pluck(:id)

      return unless ids.present?

      User::Notification.where(id: ids).update_all(status: :read, read_at: Time.current)
      NotificationsChannel.broadcast_changed!(user)
    end
  end
end
