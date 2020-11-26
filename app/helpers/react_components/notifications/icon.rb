module ReactComponents
  module Notifications
    class Icon < ReactComponent
      initialize_with :user

      def to_s
        super(
          "notifications-icon",
          { count: user.notifications.count },
          fitted: true
        )
      end
    end
  end
end
