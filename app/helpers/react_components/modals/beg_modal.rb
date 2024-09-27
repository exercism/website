module ReactComponents
  module Modals
    class BegModal < ReactComponent
      def to_s
        super("beg-modal", {
          request: {
            endpoint: Exercism::Routes.current_api_payments_subscriptions_url,
            options: {
              initial_data: AssembleCurrentSubscription.(current_user)
            }
          },
          links: {
            settings: Exercism::Routes.donations_settings_url,
            success: Exercism::Routes.donated_url
          }
        })
      end
    end
  end
end
