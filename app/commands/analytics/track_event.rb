# Sends one named event about a user to PostHog. Call it with .defer so the
# event is sent from a background job. Analytics failures must never break
# a request or a payment.
class Analytics::TrackEvent
  include Mandate

  queue_as :analytics

  initialize_with :user, :event, properties: {}, user_ip: nil, user_agent: nil

  # Current is request-scoped and empty in the background job, so this copies
  # the user's IP and user agent into the job arguments when it is deferred.
  # A value passed explicitly is kept.
  def self.defer(*args, **kwargs)
    kwargs[:user_ip] = Current.ip_address unless kwargs.key?(:user_ip)
    kwargs[:user_agent] = Current.user_agent unless kwargs.key?(:user_agent)
    super(*args, **kwargs)
  end

  def call
    return unless Analytics.client
    return unless user

    Analytics.client.capture(
      distinct_id: user.id.to_s,
      event:,
      properties: properties.to_h.symbolize_keys.merge(default_properties).merge(derived_properties)
    )
  end

  private
  def default_properties
    {
      membership_type: Analytics.membership_type(user),
      locale: user.locale.presence || I18n.default_locale.to_s
    }
  end

  def derived_properties = geoip_properties.merge(user_agent_properties)

  # With a real user IP, PostHog's GeoIP transformation resolves it into a
  # location. Without one, GeoIP is disabled for the event, because PostHog
  # would otherwise resolve the location of our servers.
  def geoip_properties
    return { "$geoip_disable": true } if user_ip.blank?

    { "$ip": user_ip }
  end

  # PostHog's "User Agent Populator" transformation parses $useragent into
  # $browser, $os, $device_type and so on. It must be enabled in the PostHog
  # project (Data pipeline, then Transformations).
  def user_agent_properties
    return {} if user_agent.blank?

    { "$useragent": user_agent }
  end
end
