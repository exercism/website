module ReactComponents
  module Common
    class NotificationsMenu < ReactComponent
      def to_s
        super(
          "common-notifications-menu",
          { endpoint: Exercism::Routes.api_notifications_url }
        )
      end
    end
  end
end
