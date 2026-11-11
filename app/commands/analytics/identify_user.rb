# Updates a user's person properties in PostHog. Each call is a billed
# event, so this is only deferred when one of these properties changes
# after signup. The signup event sets them for new users itself.
class Analytics::IdentifyUser
  include Mandate

  queue_as :background

  initialize_with :user

  def self.person_properties(user)
    {
      handle: user.handle,
      membership_type: Analytics.membership_type(user),
      locale: user.locale.presence || I18n.default_locale.to_s,
      signup_date: user.created_at.to_date.iso8601,
      is_internal: user.staff?
    }
  end

  def call
    return unless Analytics.client
    return unless user

    # PostHog would otherwise resolve the location of our servers.
    Analytics.client.identify(
      distinct_id: user.id.to_s,
      properties: self.class.person_properties(user).merge("$geoip_disable": true)
    )
  end
end
