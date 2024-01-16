class ReactComponents::Donations::SubscriptionForm < ReactComponents::ReactComponent
  def to_s
    super(
      "donations-subscription-form",
      {
        links: { cancel:, update: }
      }.merge(donation_attributes)
    )
  end

  private
  def cancel
    return nil unless subscription.stripe?

    Exercism::Routes.cancel_api_payments_subscription_url(subscription)
  end

  def donation_attributes = subscription.attributes.slice("provider", "amount_in_cents")

  def update
    return nil unless subscription.stripe?

    Exercism::Routes.update_amount_api_payments_subscription_url(subscription)
  end

  memoize
  def subscription
    current_user.current_subscription
  end
end
