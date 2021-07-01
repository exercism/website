module ReactComponents
  module Settings
    class DeleteAccountButton < ReactComponent
      def to_s
        super("settings-delete-account-button", {
          handle: current_user.handle,
          links: {
            delete: Exercism::Routes.destroy_account_settings_url
          }
        })
      end
    end
  end
end
