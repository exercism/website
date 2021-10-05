module ReactComponents
  module Modals
    class FirstTimeModal < ReactComponent
      def to_s
        return if current_user.introducer_dismissed?(slug)

        super(
          "modals-first-time-modal",
          {
            endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug),
            contributors: contributors.sort_by { rand }.map do |c|
              {
                handle: c.handle,
                avatar_url: c.avatar_url
              }
            end
          }
        )
      end

      private
      def contributors
        User.where(id: [3441, 23_560, 210_814, 38_366, 91_576, 76_721, 88_486, 56_500, 3256, 132_998, 126_320, 266_545, 204_014, 1530, 165_928, 312_980, 2435, 163_024, 416_860, 199_082, 138_856, 352_795, 224_043, 504_026]) # rubocop:disable Layout/LineLength
      end

      def slug
        "v3-modal"
      end
    end
  end
end
