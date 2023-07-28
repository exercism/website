module ReactComponents
  module Settings
    class ThemePreferenceForm < ReactComponent
      def to_s
        super("settings-theme-preference-form", {
          default_theme_preference:,
          is_premium: current_user.premium?,
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url,
            insiders_path: Exercism::Routes.insiders_path,
            premium_path: Exercism::Routes.premium_path
          }
        })
      end

      def default_theme_preference
        current_user.preferences.theme || 'light'
      end
    end
  end
end
