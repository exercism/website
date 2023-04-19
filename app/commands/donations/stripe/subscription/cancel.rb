# This cancels a payment within Stripe, and updates a record
# within our database.
class Donations::Stripe::Subscription::Cancel
  include Mandate

  initialize_with :subscription

  def call
    begin
      Stripe::Subscription.cancel(subscription.external_id)
    rescue Stripe::InvalidRequestError
      data = Stripe::Subscription.retrieve(subscription.external_id)

      # Raise if we failed to cancel an active subscription
      raise if data.status == 'active'
    end

    Donations::Subscription::Deactivate.(subscription)
  end
end
