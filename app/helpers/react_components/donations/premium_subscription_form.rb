class ReactComponents::Donations::PremiumSubscriptionForm < ReactComponents::ReactComponent
  def to_s
    super(
      "premium-subscription-form",
      {
        links: { cancel:, insiders_path: Exercism::Routes.insiders_path, premium_redirect_link: Exercism::Routes.premium_path },
        user_signed_in: user_signed_in?,
        captcha_required: !current_user || current_user.captcha_required?,
        recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key)
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
