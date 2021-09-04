class User::Notification
  class CreateEmailOnly
    include Mandate

    initialize_with :user, :type, :params

    def call
      exercise = params.delete(:exercise)
      track = params.delete(:track) || exercise&.track

      klass = "user/notifications/#{type}_notification".camelize.constantize
      klass.create!(
        user: user,
        status: :email_only,
        track: track,
        exercise: exercise,
        params: params
      ).tap do |notification|
        User::Notification::SendEmail.(notification)
      end
    end
  end
end
