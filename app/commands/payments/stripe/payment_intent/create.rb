class Payments::Stripe::PaymentIntentError < RuntimeError
end

class Payments::Stripe::PaymentIntent::Create
  include Mandate

  initialize_with :user_or_email, :type, :amount_in_cents, trigger: nil

  def call
    if invalid_user_or_email?
      Sentry.capture_exception(
        Payments::Stripe::PaymentIntentError.new("Invalid user or email trying to make donation: #{user_or_email}")
      )
      return
    end

    customer_id = user ?
      Payments::Stripe::Customer::CreateForUser.(user) :
      Payments::Stripe::Customer::CreateForEmail.(user_or_email)

    case type.to_sym
    when :subscription
      payment_intent = Payments::Stripe::PaymentIntent::CreateForSubscription.(customer_id, amount_in_cents, trigger: valid_trigger)
    else
      payment_intent = Payments::Stripe::PaymentIntent::CreateForPayment.(customer_id, amount_in_cents, trigger: valid_trigger)
    end

    track_checkout_started!
    payment_intent
  end

  private
  def track_checkout_started!
    return unless user

    Analytics::TrackEvent.defer(
      user,
      "checkout_started",
      properties: Analytics.checkout_properties(trigger: valid_trigger, payment_type:, amount_in_cents:)
    )
  end

  def payment_type = type.to_sym == :subscription ? "subscription" : "payment"

  # Stripe stores the trigger with the payment, so the success event can
  # record where the checkout started, including when it only completes
  # through a webhook.
  def valid_trigger = trigger.to_s.presence_in(Analytics::TRIGGERS)

  def invalid_user_or_email?
    user_or_email.is_a?(User) ?
      User::BlockDomain.blocked?(user:) :
      User::BlockDomain.blocked?(email: user_or_email)
  end

  memoize
  def user
    return user_or_email if user_or_email.is_a?(User)

    User.find_by(email: user_or_email)
  end
end
