module ReactComponents
  module Profile
    class AvatarSelector < ReactComponent
      def to_s
        super("profile-avatar-selector", {
          user: {
            avatar_url: current_user.avatar_url,
            handle: current_user.handle
          },
          links: {
            update: Exercism::Routes.api_user_url(current_user)
          }
        })
      end
    end
  end
end
