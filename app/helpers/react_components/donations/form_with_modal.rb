module ReactComponents
  module Donations
    class FormWithModal < ReactComponent
      def to_s
        super(
          "donations-with-modal-form",
          {
            request: {
              endpoint: Exercism::Routes.active_or_overdue_api_payments_subscriptions_url,
              options: {
                initial_data: AssembleActiveOrOverdueSubscription.(current_user)
              }
            },
            user_signed_in: user_signed_in?,
            captcha_required: !current_user || current_user.captcha_required?,
            recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key),
            links: {
              settings: Exercism::Routes.donations_settings_url,
              donate: Exercism::Routes.donate_url
            }
          }
        )
      end
    end
  end
end
