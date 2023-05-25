module ReactComponents
  module Common
    class ThemeToggleButton < ReactComponent
      initialize_with enabled: true

      def to_s
        super("common-theme-toggle-button", {
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url,
            # TODO: user the correct link here
            premium: Exercism::Routes.premium_path
          },
          disabled: !enabled
        })
      end
    end
  end
end
