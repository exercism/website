module ReactComponents
  module Stripe
    class Form < ReactComponent
      initialize_with :user

      def to_s
        super(
          "donations-with-modal-form",
          {
          }
        )
      end
    end
  end
end
