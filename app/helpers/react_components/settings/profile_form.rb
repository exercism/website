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
          links: {
            update: Exercism::Routes.api_settings_url
          }
        })
      end
    end
  end
end
