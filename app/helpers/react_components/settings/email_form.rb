module ReactComponents
  module Settings
    class EmailForm < ReactComponent
      def to_s
        super("settings-email-form", {
          email: current_user.email,
          links: {
            update: Exercism::Routes.sudo_update_api_settings_url
          }
        })
      end
    end
  end
end
