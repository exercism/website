module Donations
  class Subscription
    class Create
      include Mandate

      initialize_with :user, :stripe_data

      def call
        Donations::Subscription.create_or_find_by!(
          user: user,
          stripe_id: stripe_data.id
        ) do |sub|
          sub.amount_in_cents = stripe_data.plan.amount
        end
      end
    end
  end
end
