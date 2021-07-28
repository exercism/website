module ReactComponents
  module Donations
    class FormWithModal < ReactComponent
      initialize_with :user

      def to_s
        super(
          "donations-with-modal-form",
          {
            existing_subscription_amount_in_dollars: current_user&.active_donation_subscription_amount_in_dollars
          }
        )
      end
    end
  end
end
