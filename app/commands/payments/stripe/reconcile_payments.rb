class Payments::Stripe::ReconcilePayments
  include Mandate

  initialize_with since: 90.days.ago

  def call
    Stripe::PaymentIntent.list({
      limit: 100,
      status: 'succeeded',
      created: { gte: since.to_i },
      expand: ['data.latest_charge']
    }).auto_paging_each do |payment_intent|
      next if existing_payment_ids.include?(payment_intent.id)
      next unless payment_intent.customer

      sync_payment_intent(payment_intent)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  private
  def sync_payment_intent(payment_intent)
    return unless should_record_payment?(payment_intent)

    user = find_user(payment_intent)
    return unless user

    subscription = find_subscription(user, payment_intent)
    receipt_url = payment_intent.latest_charge&.receipt_url

    Payments::Payment::Create.(
      user, :stripe, payment_intent.id,
      payment_intent.amount, receipt_url,
      subscription:,
      donated_at: Time.at(payment_intent.created).utc,
      send_email: false
    )
  end

  def should_record_payment?(payment_intent)
    return true if payment_intent.invoice

    charge = payment_intent.latest_charge
    charge&.billing_details&.email.blank?
  rescue StandardError
    true
  end

  def find_user(payment_intent)
    User.with_data.find_by(data: { stripe_customer_id: payment_intent.customer })
  end

  def find_subscription(user, payment_intent)
    return nil unless payment_intent.invoice

    invoice = Stripe::Invoice.retrieve(payment_intent.invoice)
    return nil unless invoice.subscription

    user.subscriptions.find_by(external_id: invoice.subscription, provider: :stripe)
  end

  memoize
  def existing_payment_ids = Payments::Payment.stripe.pluck(:external_id).to_set
end
