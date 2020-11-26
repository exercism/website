module ReactComponents
  module Common
    class NotificationsIcon < ReactComponent
      initialize_with :user

      def to_s
        super(
          "common-notifications-icon",
          { count: user.notifications.count }
        )
      end
    end
  end
end
