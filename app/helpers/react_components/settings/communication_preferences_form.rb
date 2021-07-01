module ReactComponents
  module Settings
    class CommunicationPreferencesForm < ReactComponent
      def to_s
        super("settings-communication-preferences-form", {
          preferences: SerializeCommunicationPreferences.(current_user.communication_preferences),
          links: {
            update: Exercism::Routes.api_settings_communication_preferences_url
          }
        })
      end
    end
  end
end
