module ReactComponents
  module Common
    class NotificationsMenu < ReactComponent
      initialize_with :notifications, :unrevealed_badges

      def to_s
        super(
          "common-notifications-menu",
          { notifications: notifications, unrevealed_badges: unrevealed_badges }
        )
      end
    end
  end
end
