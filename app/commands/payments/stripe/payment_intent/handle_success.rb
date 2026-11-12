class Payments::Stripe::PaymentIntent::HandleSuccess
  include Mandate

  def initialize(id: nil, payment_intent: nil)
    raise "Specify either id or payment intent" unless id || payment_intent

    @id = id
    @payment_intent = payment_intent
  end

  def call
    return unless payment_intent_succeeded?
    return unless user
    return unless should_record_payment?
    return if subscription_data && !subscription_paid?

    was_insider = user.insider?
    subscription = Payments::Stripe::Subscription::Create.(user, subscription_data) if subscription_data
    payment = Payments::Stripe::Payment::Create.(user, payment_intent, subscription:)
    track_checkout_succeeded!(payment, was_insider)
    payment
  end

  private
  attr_reader :id

  # This runs up to three times for each payment (from the browser and from
  # two webhooks), and again for every subscription renewal. The event is
  # only sent for the call that created the payment record, and only for a
  # checkout, meaning a one-off payment or a subscription's first invoice.
  def track_checkout_succeeded!(payment, was_insider)
    return unless payment&.previously_new_record?
    return if subscription_data && invoice.billing_reason != "subscription_create"

    Analytics::TrackEvent.defer(
      user,
      "checkout_succeeded",
      properties: Analytics.checkout_properties(
        trigger:,
        payment_type: subscription_data ? "subscription" : "payment",
        amount_in_cents: payment_intent.amount
      ).merge(became_insider: !was_insider && user.reload.insider?),
      snapshot_activity: true
    )
  end

  # The trigger is stored on the subscription for a subscription, and on
  # the payment intent for a one-off payment.
  def trigger
    metadata = subscription_data ? subscription_data.metadata : payment_intent.metadata
    metadata&.[](:trigger)
  end

  def payment_intent_succeeded? = payment_intent.status == "succeeded"

  # A subscription only counts once its first invoice has been paid.
  def subscription_paid?
    return true if invoice.status == "paid"

    %w[active trialing].include?(subscription_data.status)
  end

  memoize
  def user
    raise "No customer in the payment intent" unless payment_intent.customer

    User.with_data.find_by(data: { stripe_customer_id: payment_intent.customer })
  end

  memoize
  def invoice
    return unless payment_intent.invoice

    Stripe::Invoice.retrieve(payment_intent.invoice)
  end

  memoize
  def subscription_data
    return unless invoice&.subscription

    Stripe::Subscription.retrieve(invoice.subscription)
  end

  memoize
  def should_record_payment?
    return true if subscription_data

    # Bootcamp payments were created via Checkout Sessions; donations are not.
    Stripe::Checkout::Session.list({ payment_intent: payment_intent.id }).data.empty?
  rescue StandardError
    true
  end

  memoize
  def payment_intent
    @payment_intent || Stripe::PaymentIntent.retrieve(id)
  end
end
