class Payments::Stripe::PaymentIntent::HandleSuccess
  include Mandate

  def initialize(id: nil, payment_intent: nil)
    raise "Specify either id or payment intent" unless id || payment_intent

    @id = id
    @payment_intent = payment_intent
  end

  def call
    return unless user

    subscription = Payments::Stripe::Subscription::Create.(user, subscription_data) if subscription_data
    Payments::Stripe::Payment::Create.(user, payment_intent, subscription:)
  end

  private
  attr_reader :id

  memoize
  def user
    raise "No customer in the payment intent" unless payment_intent.customer

    User.with_data.find_by(data: { stripe_customer_id: payment_intent.customer })
  end

  memoize
  def subscription_data
    return unless payment_intent.invoice

    invoice = Stripe::Invoice.retrieve(payment_intent.invoice)
    return unless invoice.subscription

    Stripe::Subscription.retrieve(invoice.subscription)
  end

  memoize
  def payment_intent
    @payment_intent || Stripe::PaymentIntent.retrieve(id)
  end
end
