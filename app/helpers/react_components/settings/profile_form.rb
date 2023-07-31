module ReactComponents
  module Settings
    class ProfileForm < ReactComponent
      def to_s
        super("settings-profile-form", {
          user: {
            name: current_user.name,
            location: current_user.location,
            bio: current_user.bio
          },
          profile:,
          links: {
            update: Exercism::Routes.api_settings_url
          }
        })
      end

      private
      def profile
        return if current_user.profile.blank?

        {
          twitter: current_user.profile.twitter,
          github: current_user.profile.github,
          linkedin: current_user.profile.linkedin
        }
      end
    end
  end
end
