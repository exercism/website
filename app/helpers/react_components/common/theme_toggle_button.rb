module ReactComponents
  module Common
    class ThemeToggleButton < ReactComponent
      initialize_with enabled: true, default_theme:

      def to_s
        super("common-theme-toggle-button", {
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url,
            premium: Exercism::Routes.premium_path
          },
          disabled: !enabled,
          default_theme:
        })
      end
    end
  end
end
