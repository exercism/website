module ReactComponents
  module Profile
    class AvatarSelector < ReactComponent
      def to_s
        super("profile-avatar-selector", {
          user: {
            avatar_url: current_user.avatar_url,
            has_avatar: current_user.has_avatar?,
            handle: current_user.handle
          },
          links: {
            update: Exercism::Routes.api_user_url,
            delete: Exercism::Routes.api_user_profile_photo_url
          }
        })
      end
    end
  end
end
