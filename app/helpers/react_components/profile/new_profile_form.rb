module ReactComponents
  module Profile
    class NewProfileForm < ReactComponent
      def to_s
        super("profile-new-profile-form", {
          user: {
            avatar_url: current_user.avatar_url,
            has_avatar: current_user.has_avatar?,
            handle: current_user.handle
          },
          fields: {
            name: current_user.name || "",
            location: current_user.location || "",
            bio: current_user.bio || ""
          },
          links: {
            create: Exercism::Routes.api_profile_url,
            update: Exercism::Routes.api_user_url,
            delete: Exercism::Routes.api_user_profile_photo_url
          }
        })
      end
    end
  end
end
