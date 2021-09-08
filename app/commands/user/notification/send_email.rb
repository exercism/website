class User::Notification
  class SendEmail
    include Mandate

    initialize_with :notification

    def call
      # We start by doing checks to see if we should send based
      # on the state of the notification. We hope to catch things
      # here to avoid locking
      return unless notification.email_pending?
      return unless guard_notification_needs_sending!

      # Do this first, so we can do it outside of the lock
      return unless guard_user_wants_email!

      # TODO: (Required) Check for daily-batch preference

      # We now lock and recheck things. We do the rechecking in the locked
      # record to avoid race conditions.
      notification.with_lock do
        return unless notification.email_pending?
        return unless guard_notification_needs_sending!

        NotificationsMailer.with(notification: notification).
          send(notification.email_type).deliver_later

        notification.email_sent!
      end
    end

    def guard_notification_needs_sending!
      return true if notification.unread? || notification.email_only?

      notification.email_skipped!
      false
    end

    def guard_user_wants_email!
      conditions = [
        user.communication_preferences&.send(notification.email_key),
        !user.email.ends_with?("users.noreply.github.com")
      ]

      return true if conditions.all?

      notification.email_skipped!
      false
    end

    memoize
    delegate :user, to: :notification
  end
end
