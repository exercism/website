module ReactComponents
  module Modals
    class FirstTimeModal < ReactComponent
      def to_s
        return if current_user.introducer_dismissed?(slug)

        super(
          "modals-first-time-modal",
          {
            endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug),
            contributors: contributors.map do |c|
              {
                handle: c.handle,
                avatar_url: c.avatar_url
              }
            end
          }
        )
      end

      private
      # TODO: change this
      def contributors
        User.all
      end

      def slug
        "v3-modal"
      end
    end
  end
end
