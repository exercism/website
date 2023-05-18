module ReactComponents
  module Common
    class ThemeToggleButton < ReactComponent
      def to_s
        super("common-theme-toggle-button", {
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url
          }
        })
      end
    end
  end
end
