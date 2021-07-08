module ReactComponents
  module Stripe
    class Form < ReactComponent
      initialize_with :user

      def to_s
        super(
          "stripe-form",
          {
          }
        )
      end
    end
  end
end
