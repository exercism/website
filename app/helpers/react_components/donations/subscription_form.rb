class ReactComponents::Donations::SubscriptionForm < ReactComponents::ReactComponent
  def to_s
    super(
      "donations-subscription-form",
      {
        amount_in_cents: current_user.current_current_active_donation_subscription_amount_in_cents,
        links: { cancel:, update: }
      }
    )
  end

  private
  def cancel
    return nil unless current_user.current_active_donation_subscription.stripe?

    Exercism::Routes.cancel_api_payments_subscription_url(current_user.current_active_donation_subscription)
  end

  def update
    return nil unless current_user.current_active_donation_subscription.stripe?

    Exercism::Routes.update_amount_api_payments_subscription_url(current_user.current_active_donation_subscription)
  end
end
