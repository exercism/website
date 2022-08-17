class SerializeUserPreferences
  include Mandate

  initialize_with :preferences

  def call = { automation: serialize(User::Preferences.automation_keys) }

  private
  def serialize(keys)
    keys.map do |key|
      {
        key:,
        value: preferences.send(key),
        label: I18n.t("user_preferences.#{key}")
      }
    end
  end
end
