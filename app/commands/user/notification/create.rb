class User::Notification::Create
  include Mandate

  queue_as :notifications

  initialize_with :user, :type, params: Mandate::KWARGS

  def call
    exercise = params.delete(:exercise)
    track = params.delete(:track) || exercise&.track

    klass = "user/notifications/#{type}_notification".camelize.constantize
    notification = klass.new(
      user:,
      track:,
      exercise:,
      params:
    )

    # Don't attempt to create a notification when there already is one
    # This optimizes for scripts that create notifications but where
    # the notification has usually already been created
    existing_notification = user.notifications.find_by(uniqueness_key: notification.uniqueness_key)
    return existing_notification if existing_notification.present?

    begin
      notification.save!
      notification.tap do
        User::Notification::Activate.defer(notification, wait: 5.seconds)

        NotificationsChannel.broadcast_pending!(user, notification)
      end
    rescue ActiveRecord::RecordNotUnique
      # If the notification is already created, then don't
      # blow up. This could happen for multiple reasons and
      # it's not necessarily an error.
      user.notifications.find_by(uniqueness_key: notification.uniqueness_key)
    end
  end
end
