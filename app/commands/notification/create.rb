class Notification
  class Create
    include Mandate

    initialize_with :user, :type, :params

    def call
      klass = "notifications/#{type}_notification".camelize.constantize

      klass.create!(user: user, params: params).tap do
        NotificationsChannel.broadcast_changed(user)
      end
    end
  end
end
