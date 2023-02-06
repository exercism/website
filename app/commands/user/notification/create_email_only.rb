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

    begin
      notification.save!
      notification.tap do
        User::Notification::SendEmail.(notification)
      end
    rescue ActiveRecord::RecordNotUnique
      # If the notification is already created, then don't
      # blow up. This could happen for multiple reasons and
      # it's not necessarily an error.
      user.notifications.find_by(uniqueness_key: notification.uniqueness_key)
    end
  end
end
