module ReactComponents
  module Notifications
    class Icon < ReactComponent
      initialize_with :user

      def to_s
        super("notifications-icon", { count: user.notifications.count })
      end
    end
  end
end
