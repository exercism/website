# This creates a Stripe-hosted customer portal session, where a donor can
# update the card used for their recurring donation. It returns the URL of
# the session, or nil if the user has no Stripe customer.
class Payments::Stripe::BillingPortal::CreateSession
  include Mandate

  initialize_with :user, :return_url

  def call
    return nil if user.stripe_customer_id.blank?

    Stripe::BillingPortal::Session.create(
      customer: user.stripe_customer_id,
      return_url:
    ).url
  end
end
