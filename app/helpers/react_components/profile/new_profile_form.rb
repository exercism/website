module ReactComponents
  module Profile
    class NewProfileForm < ReactComponent
      def to_s
        super("profile-new-profile-form", {
          user: {
            avatar_url: current_user.avatar_url,
            is_avatar_attached: current_user.avatar.attached?,
            handle: current_user.handle
          },
          fields: {
            name: current_user.name || "",
            location: current_user.location || "",
            bio: current_user.bio || ""
          },
          links: {
            create: Exercism::Routes.api_profile_url,
            update: Exercism::Routes.api_user_url(current_user)
          }
        })
      end
    end
  end
end
