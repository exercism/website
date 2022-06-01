class SerializeCommunicationPreferences
  include Mandate

  initialize_with :preferences

  def call
    User::CommunicationPreferences.keys.map do |key|
      {
        key:,
        value: preferences.send(key),
        label: I18n.t("communication_preferences.#{key}")
      }
    end
  end
end
