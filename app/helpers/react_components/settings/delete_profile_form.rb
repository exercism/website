module ReactComponents
  module Settings
    class DeleteProfileForm < ReactComponent
      def to_s
        super("settings-delete-profile-form", {
          links: {
            delete: Exercism::Routes.api_profile_url
          }
        })
      end
    end
  end
end
