module ReactComponents
  module Settings
    class UserPreferencesForm < ReactComponent
      def to_s
        super("settings-user-preferences-form", {
          preferences: SerializeUserPreferences.(current_user.preferences),
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url
          }
        })
      end
    end
  end
end
