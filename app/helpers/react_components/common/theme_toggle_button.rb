module ReactComponents
  module Common
    class ThemeToggleButton < ReactComponent
      initialize_with :disabled

      def to_s
        super("common-theme-toggle-button", {
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url
          },
          disabled:
        })
      end
    end
  end
end
