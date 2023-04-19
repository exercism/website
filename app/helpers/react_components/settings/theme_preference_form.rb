module ReactComponents
  module Settings
    class ThemePreferenceForm < ReactComponent
      def to_s
        super("settings-theme-preference-form", {
          default_theme_preference: 'system',
          links: {
            update: Exercism::Routes.api_settings_url
          }
        })
      end
    end
  end
end
