module ReactComponents
  module Settings
    class PhotoForm < ReactComponent
      def to_s
        super("settings-photo-form", {
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
