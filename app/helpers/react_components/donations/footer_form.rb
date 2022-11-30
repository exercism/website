module ReactComponents
  module Donations
    class FooterForm < ReactComponent
      def to_s
        super(
          "donations-footer-form",
          {
            request: {
              endpoint: Exercism::Routes.api_donations_active_subscription_url,
              options: {
                initial_data: AssembleActiveSubscription.(current_user)
              }
            },
            user_signed_in: user_signed_in?,
            captcha_required: !current_user&.github_auth?,
            recaptcha_site_key: '6LfFYEUjAAAAAH9eRl1qeO2R9aXzdXGnAybe6ulM', # TODO: use secret
            links: {
              settings: Exercism::Routes.donations_settings_url
            }
          }
        )
      end
    end
  end
end
