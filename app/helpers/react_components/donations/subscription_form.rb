module ReactComponents
  module Donations
    class SubscriptionForm < ReactComponent
      def to_s
        super(
          "donations-subscription-form",
          {
            amount_in_dollars: current_user.active_donation_subscription_amount_in_dollars
          }
        )
      end
    end
  end
end
