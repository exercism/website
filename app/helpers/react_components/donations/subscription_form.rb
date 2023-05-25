module ReactComponents
  module Donations
    class SubscriptionForm < ReactComponent
      def to_s
        super(
          "donations-subscription-form",
          {
            amount_in_cents: current_user.active_donation_subscription_amount_in_cents,
            links: {
              cancel: Exercism::Routes.cancel_api_payments_subscription_url(current_user.active_donation_subscription),
              update: Exercism::Routes.update_amount_api_payments_subscription_url(current_user.active_donation_subscription)
            }
          }
        )
      end
    end
  end
end
