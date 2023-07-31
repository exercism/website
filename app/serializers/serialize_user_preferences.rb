class SerializeUserPreferences
  include Mandate

  initialize_with :preferences

  def call = {
    automation: serialize(User::Preferences.automation_keys)
  }

  private
  def serialize(keys)
    keys.map do |key|
      label = I18n.t("user_preferences.#{key}", default: nil)
      next unless label

      {
        key:,
        value: preferences.send(key),
        label:
      }
    end.compact
  end
end
