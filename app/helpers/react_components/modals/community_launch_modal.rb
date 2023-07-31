module ReactComponents
  module Modals
    class CommunityLaunchModal < ReactComponent
      def to_s
        return if current_user.introducer_dismissed?(slug)

        super(
          "modals-community-launch-modal",
          {
            endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug),
            jonathan_image_url: image_url('team/jonathan.jpg')
          }
        )
      end

      private
      def slug
        "community-launch-modal"
      end
    end
  end
end
