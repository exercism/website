class User
  module Notifications
    class AddedToContributorsPageNotification < Notification
      def url
        Exercism::Routes.contributing_contributors_url
      end

      def i18n_params
        {}
      end

      def image_type = :icon

      def image_path = "icons/contributors.svg"

      def guard_params
        "" # Users should only have this badge once
      end

      def email_communication_preferences_key = "email_on_general_update_notification"
    end
  end
end
