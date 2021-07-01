module ReactComponents
  module Settings
    class HandleForm < ReactComponent
      def to_s
        super("settings-handle-form", {
          handle: current_user.handle,
          links: {
            update: Exercism::Routes.sudo_update_api_settings_url
          }
        })
      end
    end
  end
end
