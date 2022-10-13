class User
  module Notifications
    class NudgeToRequestMentoringNotification < Notification
      def url
        Exercism::Routes.track_url(track, notification_uuid: uuid, anchor: "mentoring")
      end

      def image_type
        :icon
      end

      def image_path = "icons/mentoring-gradient.svg"

      def guard_params
        ""
      end

      def email_communication_preferences_key
        :email_on_nudge_notification
      end
    end
  end
end
