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
