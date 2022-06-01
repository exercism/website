# This responds to a new subscription that has been made
# and creates a record of it in our database. The actual
# creation of the subscription within Stripe happens through
# "payment intents".
module Donations
  class Subscription
    class Create
      include Mandate

      initialize_with :user, :stripe_data

      def call
        Donations::Subscription.create!(
          user:,
          stripe_id: stripe_data.id,
          amount_in_cents: stripe_data.items.data[0].price.unit_amount,
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
