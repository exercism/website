module ViewComponents
  module Notifications
    class Icon < ViewComponent
      initialize_with :user

      def to_s
        react_component("notifications-icon", { count: user.notifications.count })
      end
    end
  end
end
