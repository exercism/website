module Donations
  class Subscription
    class Create
      include Mandate

      initialize_with :user, :stripe_data

      def call
        Donations::Subscription.create!(
          user: user,
          stripe_id: stripe_data.id,
          amount: stripe_data.plan.amount
        )
      end
    end
  end
end
