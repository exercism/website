module ReactComponents
  module Settings
    class PasswordForm < ReactComponent
      def to_s
        super("settings-password-form", {
          links: {
            update: Exercism::Routes.sudo_update_api_settings_url
          }
        })
      end
    end
  end
end
