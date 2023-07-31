module ReactComponents
  module Donations
    class FooterForm < ReactComponent
      def to_s
        super(
          "donations-footer-form",
          {
            request: {
              endpoint: Exercism::Routes.api_payments_active_subscription_url(product: :donation),
              options: {
                initial_data: AssembleActiveSubscription.(current_user, :donation)
              }
            },
            user_signed_in: user_signed_in?,
            captcha_required: !current_user || current_user.captcha_required?,
            recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key),
            links: {
              settings: Exercism::Routes.donations_settings_url
            }
          }
        )
      end
    end
  end
end
