module ReactComponents
  module Settings
    class ThemePreferenceForm < ReactComponent
      def to_s
        super("settings-theme-preference-form", {
          default_theme_preference:,
          insiders_status: current_user.insiders_status,
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url,
            insiders_path: Exercism::Routes.insiders_path
          }
        })
      end

      def default_theme_preference
        current_user.preferences.theme || 'light'
      end
    end
  end
end
