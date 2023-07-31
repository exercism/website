class SerializeCommunicationPreferences
  include Mandate

  initialize_with :preferences

  def call
    {
      mentoring: serialize(User::CommunicationPreferences.mentoring_keys),
      product: serialize(User::CommunicationPreferences.product_keys)
    }
  end

  private
  def serialize(keys)
    keys.map do |key|
      {
        key:,
        value: preferences.send(key),
        label: I18n.t("communication_preferences.#{key}")
      }
    end
  end
end
