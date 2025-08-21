class User::Notification::Activate
  include Mandate

  initialize_with :notification

  def call
    notification.with_lock do
      return unless notification.pending?

      notification.update_column(:status, :unread)
    end

    NotificationsChannel.broadcast_changed!(notification.user)
    User::Notification::SendEmail.(notification)
  end
end
