# This responds to a new payment that has been made
# and creates a record of it in our database. The actual
# creation of the payment within Stripe happens through
# "payment intents".
class Payments::Stripe::Payment::Create
  class SubscriptionNotCreatedError < RuntimeError
    def initialize
      super "Subscription not yet created. Wait for webhook then try again."
    end
  end

  include Mandate

  initialize_with :user, :stripe_data, subscription: nil

  def call
    Payments::Payment::Create.(user, :stripe, product, external_id, amount_in_cents, external_receipt_url, subscription:)
  end

  private
  def external_id = stripe_data.id
  def external_receipt_url = stripe_data.charges.first.receipt_url
  def amount_in_cents = stripe_data.amount

  def product
    return subscription.product if subscription

    # Premium payments are always linked to a subscription, even one-off payments
    :donation
  end

  memoize
  def subscription
    return @subscription if @subscription

    return nil unless stripe_data.invoice

    invoice = Stripe::Invoice.retrieve(stripe_data.invoice)
    return nil unless invoice.subscription

    begin
      user.payment_subscriptions.find_by!(external_id: invoice.subscription, provider: :stripe)
    rescue ActiveRecord::RecordNotFound
      raise SubscriptionNotCreatedError
    end
  end
end
