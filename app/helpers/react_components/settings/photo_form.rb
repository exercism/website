module ReactComponents
  module Settings
    class PhotoForm < ReactComponent
      def to_s
        super("settings-photo-form", {
          user: {
            avatar_url: current_user.avatar_url,
            is_avatar_attached: current_user.avatar.attached?,
            handle: current_user.handle
          },
          links: {
            destroy: Exercism::Routes.api_user_profile_photo_url,
            update: Exercism::Routes.api_user_url(current_user)
          }
        })
      end
    end
  end
end
