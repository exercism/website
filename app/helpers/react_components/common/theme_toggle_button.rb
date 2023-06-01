module ReactComponents
  module Common
    class ThemeToggleButton < ReactComponent
      initialize_with user: nil

      def to_s
        super("common-theme-toggle-button", {
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url,
            premium: Exercism::Routes.premium_path
          },
          disabled: !user.premium?,
          default_theme: user.preferences.theme
        })
      end
    end
  end
end
