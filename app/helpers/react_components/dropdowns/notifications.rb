module ReactComponents
  module Dropdowns
    class Notifications < ReactComponent
      def to_s
        super(
          "dropdowns-notifications",
          { endpoint: Exercism::Routes.api_notifications_url(order: :unread_first) }
        )
      end
    end
  end
end
