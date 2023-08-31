class Payments::Stripe::Payment::SyncAll
  include Mandate

  def call
    Stripe::Event.list({ limit: 100, type: 'payment_intent.succeeded' }).auto_paging_each do |event|
      next if existing_payment_ids.include?(event.data.object.id)

      Payments::Stripe::HandleEvent.(event)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  private
  memoize
  def existing_payment_ids = Payments::Payment.stripe.pluck(:external_id)
end
