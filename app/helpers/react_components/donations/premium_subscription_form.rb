class ReactComponents::Donations::PremiumSubscriptionForm < ReactComponents::ReactComponent
  def to_s
    super(
      "premium-subscription-form",
      {
        amount_in_cents: current_user.current_active_premium_subscription.amount_in_cents,
        links: { cancel: }
      }
    )
  end

  private
  def cancel
    return nil unless current_user.current_active_premium_subscription.stripe?

    Exercism::Routes.cancel_api_payments_subscription_url(current_user.current_active_premium_subscription)
  end

  # TODO: add update link
end
