class User
  module Notifications
    class AcquiredBadgeNotification < Notification
      # TODO
      def url
        "#"
      end

      def i18n_params
        {
          badge_name: badge_name
        }
      end

      # TODO
      def image_type
        :icon
      end

      # TODO
      def image_url
        asset_pack_url("media/images/hero-journey.svg")
      end

      def guard_params
        "Badge##{badge.id}"
      end

      private
      def badge_name
        badge.name
      end

      def badge
        params[:badge]
      end
    end
  end
end
