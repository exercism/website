module ReactComponents
  module Dropdowns
    class Notifications < ReactComponent
      initialize_with :user

      def to_s
        super(
          "dropdowns-notifications",
          {
            default_unread_count: user.notifications.unread.count,
            endpoint: Exercism::Routes.api_notifications_url(for_header: true)
          },
          persistent: true
        )
      end
    end
  end
end
