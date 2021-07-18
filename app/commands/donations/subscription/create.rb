module Donations
  class Subscription
    class Create
      include Mandate

      initialize_with :user, :stripe_data

      def call
        Donations::Subscription.create!(
          user: user,
          stripe_id: stripe_data.id,
          amount_in_cents: stripe_data.plan.amount,
          active: true
        ).tap do
          user.update(active_donation_subscription: true)
        end
      rescue ActiveRecord::RecordNotUnique
        Donations::Subscription.find_by!(stripe_id: stripe_data.id)
      end
    end
  end
end
