class User::Notification
  class SendEmail
    include Mandate

    initialize_with :notification

    def call
      # We start by doing checks to see if we should send based
      # on the state of the notification. We hope to catch things
      # here to avoid locking
      return unless notification_needs_sending?

      # Do this first, so we can do it outside of the lock
      return unless user_wants_email?

      # TODO: Check for daily-batch preference

      # We now lock and recheck things. We do the rechecking in the locked
      # record to avoid race conditions.
      notification.with_lock do
        return unless notification_needs_sending?

        NotificationsMailer.with(notification: notification).
          mentor_started_discussion.deliver_later

        notification.email_sent!
      end
    end

    def notification_needs_sending?
      return false unless notification.unread?
      return false unless notification.email_pending?

      true
    end

    def user_wants_email?
      key = "email_on_#{notification.class.name.underscore.split('/').last}"
      user.communication_preferences&.send(key)
    end

    memoize
    delegate :user, to: :notification
  end
end
