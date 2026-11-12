# Sends an event reported by the browser to PostHog. The browser is
# untrusted, so only the events listed here are accepted, each with its own
# fixed list of properties. Values that aren't recognised are dropped.
#
# Returns false if the event isn't allowed.
class Analytics::TrackBrowserEvent
  include Mandate

  initialize_with :user, :event, properties: {}

  # The checkout events after checkout_started, which the server sends
  # itself when it creates the payment intent. A payment ends in
  # checkout_succeeded, which the server also sends.
  CHECKOUT_EVENTS = %w[checkout_submitted checkout_failed checkout_closed].freeze

  # These can fire on every page view that shows them, so each one is sent
  # at most once per user per UTC day for each value of its key property.
  DAILY_EVENTS = {
    "payment_prompt_shown" => :trigger,
    "assistant_limit_reached" => nil
  }.freeze

  ERROR_CODE_MAX_LENGTH = 100

  def call
    return false unless allowed?
    return true if DAILY_EVENTS.key?(event) && !claim_today!

    Analytics::TrackEvent.defer(user, event, properties: event_properties)
    true
  end

  private
  def allowed? = CHECKOUT_EVENTS.include?(event) || DAILY_EVENTS.key?(event)

  memoize
  def event_properties
    case event
    when "payment_prompt_shown"
      { trigger: params[:trigger].to_s.presence_in(Analytics::TRIGGERS) }.compact
    when "assistant_limit_reached"
      {}
    when "checkout_failed"
      checkout_properties.merge(
        error_code: error_code(params[:error_code]),
        decline_code: error_code(params[:decline_code])
      ).compact
    else
      checkout_properties
    end
  end

  def checkout_properties
    Analytics.checkout_properties(
      trigger: params[:trigger],
      payment_type: params[:payment_type],
      amount_in_cents: params[:amount_in_cents]
    )
  end

  def error_code(value) = value.is_a?(String) ? value[0, ERROR_CODE_MAX_LENGTH].presence : nil

  memoize
  def params = properties.to_h.symbolize_keys

  # Writing the key only succeeds if it isn't already set, so concurrent
  # requests can't both send the event.
  def claim_today!
    key_property = DAILY_EVENTS[event]
    key = ["analytics", event, user.id, event_properties[key_property], Time.current.utc.to_date].join(":")

    Rails.cache.write(key, true, unless_exist: true, expires_in: 1.day)
  end
end
