class User
  module Notifications
    class NudgeToRequestMentoringNotification < Notification
      def url
        Exercism::Routes.track_url(track, anchor: "mentoring")
      end

      def image_type
        :icon
      end

      def image_url
        asset_pack_url(
          "media/images/icons/mentoring-gradient.svg",
          host: Rails.application.config.action_controller.asset_host
        )
      end

      def guard_params
        ""
      end

      def email_communication_preferences_key
        :email_on_nudge_notification
      end
    end
  end
end
