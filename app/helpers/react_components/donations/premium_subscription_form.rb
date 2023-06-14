class ReactComponents::Donations::PremiumSubscriptionForm < ReactComponents::ReactComponent
  def to_s
    super(
      "premium-subscription-form",
      {
        links: { cancel:, update_to_monthly: update_to_plan(:month), update_to_annual: update_to_plan(:year),
                 insiders_path: Exercism::Routes.insiders_path, premium_redirect_link: Exercism::Routes.premium_path },
        user_signed_in: user_signed_in?,
        captcha_required: !current_user || current_user.captcha_required?,
        recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key)
      }.merge(premium_attributes)
    )
  end

  private
  def cancel
    return nil unless current_user.current_active_premium_subscription.stripe?

    Exercism::Routes.cancel_api_payments_subscription_url(current_user.current_active_premium_subscription)
  end

  def update_to_plan(interval)
    return nil unless current_user.current_active_premium_subscription.stripe?

    Exercism::Routes.update_plan_api_payments_subscription_url(current_user.current_active_premium_subscription, interval:)
  end

  def premium_attributes = current_user.current_active_premium_subscription.attributes.slice("provider", "amount_in_cents",
    "interval")
  # TODO: add update link
end
