class User
  module Notifications
    class AddedToContributorsPageNotification < Notification
      def url
        Exercism::Routes.contributing_contributors_url
      end

      def i18n_params
        {}
      end

      def image_type
        :icon
      end

      def image_url
        asset_pack_url(
          "media/images/icons/contributors.svg",
          host: Rails.application.config.action_controller.asset_host
        )
      end

      def guard_params
        "" # Users should only have this badge once
      end

      def email_communication_preferences_key
        "email_on_general_update_notification"
      end
    end
  end
end
