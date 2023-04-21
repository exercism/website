module ReactComponents
  module Settings
    class ThemePreferenceForm < ReactComponent
      def to_s
        super("settings-theme-preference-form", {
          default_theme_preference:,
          insiders_status: current_user.insiders_status,
          links: {
            # TODO: add this field too, check this update URL
            update: Exercism::Routes.api_settings_url,
            insiders_path: Exercism::Routes.insiders_path
          }
        })
      end

      # TODO: add these as default values in DB
      def default_theme_preference
        %i[active active_lifetime].include?(current_user.insiders_status) ? 'system' : 'light'
      end
    end
  end
end
