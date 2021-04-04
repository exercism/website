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
      ).tap do
        NotificationsChannel.broadcast_changed(user)
      end
    end
  end
end
