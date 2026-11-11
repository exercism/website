module Analytics
  HOST = "https://eu.i.posthog.com".freeze

  # The places in the UI where someone can be asked to pay. Every checkout
  # funnel event records one of these as its trigger. Unknown values are
  # dropped, because inconsistent values would fragment the funnel data
  # permanently. Keep this list in step with PaymentTrigger in
  # app/javascript/utils/analytics.ts.
  TRIGGERS = %w[
    donations_page
    footer_form
    beg_modal
    mentoring_donation_step
    insiders_page
    insiders_join_page
    assistant_upsell_modal
  ].freeze

  PAYMENT_TYPES = %w[payment subscription].freeze
  CURRENCY = "usd".freeze
  SUBSCRIPTION_INTERVAL = "month".freeze

  CLIENT_MUTEX = Mutex.new
  private_constant :CLIENT_MUTEX

  # PostHog only receives events from production. Everywhere else, or if
  # the project API key is missing from Exercism's secrets, this is nil and
  # the analytics commands return early without calling out.
  #
  # Events are sent from Sidekiq jobs, so the client runs in sync mode. Each
  # job sends its event before it finishes, so nothing is left in an
  # in-memory queue when a worker shuts down.
  def self.client
    CLIENT_MUTEX.synchronize do
      return @client if defined?(@client)

      @client = build_client
    end
  end

  def self.build_client
    return unless Rails.env.production?
    return if Exercism.secrets.posthog_api_key.blank?

    PostHog::Client.new(
      api_key: Exercism.secrets.posthog_api_key,
      host: HOST,
      sync_mode: true,
      on_error: proc { |status, error| Rails.logger.error("[PostHog] #{status}: #{error}") }
    )
  end
  private_class_method :build_client

  def self.membership_type(user)
    return "lifetime_insider" if user.lifetime_insider?
    return "insider" if user.insider?

    "free"
  end

  # The properties added to every checkout funnel event. Values that don't
  # apply, or that the browser sent but aren't recognised, are left out,
  # because PostHog would show a missing value as a literal "null".
  def self.checkout_properties(trigger:, payment_type:, amount_in_cents:)
    payment_type = payment_type.to_s.presence_in(PAYMENT_TYPES)
    amount_in_cents = Integer(amount_in_cents, exception: false) if amount_in_cents.present?

    {
      trigger: trigger.to_s.presence_in(TRIGGERS),
      payment_type:,
      amount_in_cents:,
      currency: (CURRENCY if payment_type),
      interval: (SUBSCRIPTION_INTERVAL if payment_type == "subscription")
    }.compact
  end
end
