class Payments::Stripe::PaymentIntent::CreateForPremiumSubscription
  include Mandate

  initialize_with :customer_id, :interval

  def call
    subscription = Stripe::Subscription.create(
      customer: customer_id,
      items: [{
        price:
      }],
      payment_behavior: 'default_incomplete',
      expand: ['latest_invoice.payment_intent']
    )

    subscription.latest_invoice.payment_intent
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  private
  def price
    case interval
    when :monthly
      Exercism.secrets.stripe_premium_monthly_price_id
    when :yearly
      Exercism.secrets.stripe_premium_yearly_price_id
    when :one_off
      Exercism.secrets.stripe_premium_one_off_price_id
    else
      raise Payments::Stripe::PaymentIntentError, "Unknown premium subscription interval"
    end
  end
end
