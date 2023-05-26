class ReactComponents::Donations::PremiumSubscriptionForm < ReactComponents::ReactComponent
  def to_s
    super(
      "premium-subscription-form",
      {
        links: { cancel: }
      }.merge(donation_attributes)
    )
  end

  private
  def cancel
    return nil unless current_user.current_active_premium_subscription.stripe?

    Exercism::Routes.cancel_api_payments_subscription_url(current_user.current_active_premium_subscription)
  end

  def donation_attributes = current_user.current_active_donation_subscription.attributes.slice("provider", "amount_in_cents",
    "interval")
  # TODO: add update link
end
