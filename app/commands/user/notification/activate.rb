class User::Notification
  class Activate
    include Mandate

    initialize_with :notification

    def call
      notification.with_lock do
        if notification.pending?
          notification.update_column(:status, :unread)
          NotificationsChannel.broadcast_changed!(notification.user)
        end
      end
    end
  end
end
