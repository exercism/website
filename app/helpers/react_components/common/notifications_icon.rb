module ReactComponents
  module Common
    class NotificationsIcon < ReactComponent
      initialize_with :user

      def to_s
        return nil unless user

        super(
          "common-notifications-icon",
          { count: user.notifications.count },
          fitted: true
        )
      end
    end
  end
end
