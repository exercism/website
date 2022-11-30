module ReactComponents
  module Donations
    class FormWithModal < ReactComponent
      def to_s
        super(
          "donations-with-modal-form",
          {
            request: {
              endpoint: Exercism::Routes.api_donations_active_subscription_url,
              options: {
                initial_data: AssembleActiveSubscription.(current_user)
              }
            },
            captcha_required: !current_user&.github_auth?,
            recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key),
            user_signed_in: user_signed_in?,
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
