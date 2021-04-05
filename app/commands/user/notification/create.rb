class User::Notification
  class Create
    include Mandate

    initialize_with :user, :type, :params

    def call
      exercise = params.delete(:exercise)
      track = params.delete(:track) || exercise&.track

      klass = "user/notifications/#{type}_notification".camelize.constantize
      klass.create!(
        user: user,
        track: track,
        exercise: exercise,
        params: params
      ).tap do |notification|
        ActivateUserNotificationJob.set(wait: 5.seconds).
          perform_later(notification)

        NotificationsChannel.broadcast_pending!(user, notification)
      end
    end
  end
end
