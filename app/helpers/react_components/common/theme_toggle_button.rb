module ReactComponents
  module Common
    class ThemeToggleButton < ReactComponent
      initialize_with :disabled, :default_theme

      def to_s
        super("common-theme-toggle-button", {
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url,
            # TODO: user the correct link here
            premium: Exercism::Routes.insiders_path
          },
          disabled:,
          default_theme:
        })
      end
    end
  end
end
