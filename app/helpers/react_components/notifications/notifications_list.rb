module ReactComponents
  module Notifications
    class NotificationsList < ReactComponent
      initialize_with :params

      def to_s
        super(
          "notifications-notifications-list",
          {
            request: {
              endpoint: Exercism::Routes.api_notifications_url,
              options: {
                initial_data: AssembleNotificationsList.(current_user, params)
              }
            }
          }
        )
      end
    end
  end
end
