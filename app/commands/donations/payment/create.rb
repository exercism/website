# This responds to a new payment that has been made
# and creates a record of it in our database. The actual
# creation of the payment within Stripe happens through
# "payment intents".

class Donations::Payment::Create
  class SubscriptionNotCreatedError < RuntimeError
    def initialize
      super "Subscription not yet created. Wait for webhook then try again."
    end
  end

  include Mandate

  initialize_with :user, :stripe_data, subscription: nil

  def call
    charge = stripe_data.charges.first
    Donations::Payment.create!(
      user:,
      stripe_id: stripe_data.id,
      stripe_receipt_url: charge.receipt_url,
      subscription:,
      amount_in_cents: stripe_data.amount
    ).tap do |payment|
      user.update(total_donated_in_cents: user.donation_payments.sum(:amount_in_cents))
      Donations::RegisterUserAsDonor.(user, Time.current)
      Donations::Payment::SendEmail.defer(payment)
    end
  rescue ActiveRecord::RecordNotUnique
    Donations::Payment.find_by!(stripe_id: stripe_data.id)
  end

  memoize
  def subscription
    return @subscription if @subscription

    return unless stripe_data.invoice

    invoice = Stripe::Invoice.retrieve(stripe_data.invoice)
    return unless invoice.subscription

    begin
      user.donation_subscriptions.find_by!(stripe_id: invoice.subscription)
    rescue ActiveRecord::RecordNotFound
      raise SubscriptionNotCreatedError
    end
  end
end
