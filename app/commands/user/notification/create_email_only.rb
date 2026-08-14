class User::Notification::CreateEmailOnly
  include Mandate

  initialize_with :user, :type, params: Mandate::KWARGS

  def call
    exercise = params.delete(:exercise)
    track = params.delete(:track) || exercise&.track

    klass = "user/notifications/#{type}_notification".camelize.constantize
    notification = klass.new(
      user:,
      status: :email_only,
      track:,
      exercise:,
      params:
    )

    # Don't attempt to create a notification when there already is one.
    # This optimizes for scripts that create notifications but where
    # the notification has usually already been created, and avoids
    # the DB work of an insert that's guaranteed to fail and roll back.
    # The uniqueness_key is only assigned in a before_create hook, so
    # we generate it manually here to check against.
    uniqueness_key = notification.generate_uniqueness_key!
    existing_notification = user.notifications.find_by(uniqueness_key:)
    return existing_notification if existing_notification.present?

    begin
      notification.save!
      notification.tap do
        User::Notification::SendEmail.(notification)
      end
    rescue ActiveRecord::RecordNotUnique
      # If the notification is already created, then don't
      # blow up. This could happen for multiple reasons and
      # it's not necessarily an error.
      user.notifications.find_by(uniqueness_key:)
    end
  end
end
