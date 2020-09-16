class Notification
  class Create
    include Mandate

    initialize_with :user, :type, :params

    def call
      klass = "notifications/#{type}_notification".camelize.constantize

      klass.create!(user: user, params: params).tap do
        NotificationsChannel.broadcast_to(user, {
                                            type: "notifications.changed",
                                            payload: { count: user.notifications.unread.count }
                                          })
      end
    end
  end
end
