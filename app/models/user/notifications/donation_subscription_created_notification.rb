class User
  module Notifications
    class DonationSubscriptionCreatedNotification < Notification
      params :payment

      def url
        Exercism::Routes.settings_url
      end

      def image_type; end

      def image_url; end

      def guard_params
        "Badge##{user_acquired_badge.badge_id}"
      end
    end
  end
end
