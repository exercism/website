module ReactComponents
  module Dropdowns
    class Notifications < ReactComponent
      def to_s
        super(
          "dropdowns-notifications",
          { endpoint: Exercism::Routes.api_notifications_url(for_header: true) },
          persistent: true
        )
      end
    end
  end
end
