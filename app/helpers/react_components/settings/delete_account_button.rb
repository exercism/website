module ReactComponents
  module Settings
    class DeleteAccountButton < ReactComponent
      def to_s
        super("settings-delete-account-button", {
          handle: current_user.handle,
          links: {
            delete: Exercism::Routes.temp_user_url
          }
        })
      end
    end
  end
end
