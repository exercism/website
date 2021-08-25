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
            links: {
              settings: Exercism::Routes.donations_settings_url
            }
          }
        )
      end
    end
  end
end
