# Sends user_signed_up to PostHog with first-touch attribution.
#
# The person properties travel in $set and $set_once on this event, so a
# new user doesn't also need an identify call (each one is a billed event).
#
# The attribution is mapped onto PostHog's reserved property names so its
# built-in attribution works. $referrer, $referring_domain and $current_url
# drive its channel type classification, and $set_once writes the
# $initial_* person properties used for first-touch breakdowns.
class User::TrackSignUp
  include Mandate

  initialize_with :user, attribution: {}

  def call
    Analytics::TrackEvent.defer(
      user,
      "user_signed_up",
      properties: {
        provider:,
        **attribution.symbolize_keys,
        "$referrer": referrer,
        "$referring_domain": referring_domain,
        "$current_url": landing_url,
        "$set": Analytics::IdentifyUser.person_properties(user),
        "$set_once": initial_properties
      }.compact
    )
  end

  private
  def provider = user.provider.presence || "email"

  def initial_properties
    {
      "$initial_referrer": referrer,
      "$initial_referring_domain": referring_domain,
      "$initial_current_url": landing_url,
      "$initial_utm_source": attribution["utm_source"],
      "$initial_utm_medium": attribution["utm_medium"],
      "$initial_utm_campaign": attribution["utm_campaign"],
      "$initial_utm_content": attribution["utm_content"]
    }.compact
  end

  # PostHog uses the literal value "$direct" to mean "no referrer".
  memoize
  def referrer = attribution["referrer"].presence || "$direct"

  memoize
  def referring_domain
    return "$direct" if attribution["referrer"].blank?

    URI.parse(attribution["referrer"]).host.presence || "$direct"
  rescue URI::InvalidURIError
    "$direct"
  end

  memoize
  def landing_url
    path = attribution["landing_path"]
    return nil if path.blank? || !path.start_with?("/") || path.start_with?("//")

    URI.join(Exercism::Routes.root_url, path).to_s
  rescue URI::InvalidURIError
    nil
  end
end
