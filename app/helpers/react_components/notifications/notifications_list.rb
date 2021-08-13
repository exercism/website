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
              },
              query: params.slice(*AssembleNotificationsList.keys)
            },
            links: {
              mark_as_read: Exercism::Routes.mark_batch_as_read_api_notifications_url
            }
          }
        )
      end
    end
  end
end
