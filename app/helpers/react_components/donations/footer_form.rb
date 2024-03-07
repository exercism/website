module ReactComponents
  module Donations
    class FooterForm < ReactComponent
      # this is cached in view_components/site_footer.rb
      def to_s
        super(
          "donations-footer-form",
          {
            request: {
              endpoint: Exercism::Routes.current_api_payments_subscriptions_url,
              options: {
                initial_data: AssembleCurrentSubscription.(current_user)
              }
            },
            user_signed_in: user_signed_in?,
            captcha_required: !current_user || current_user.captcha_required?,
            recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key),
            links: {
              settings: Exercism::Routes.donations_settings_url,
              success: Exercism::Routes.donated_url
            }
          }
        )
      end
    end
  end
end
