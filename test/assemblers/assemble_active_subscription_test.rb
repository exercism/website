require "test_helper"

class AssembleActiveSubscriptionTest < ActiveSupport::TestCase
  test "serialize last active subscription" do
    user = create :user
    other_user = create :user
    create(:payments_subscription, :active, user:, amount_in_cents: 100)
    subscription = create(:payments_subscription, :active, user:, amount_in_cents: 200)
    create(:payments_subscription, :canceled, user:, amount_in_cents: 300)
    create(:payments_subscription, :overdue, user:, amount_in_cents: 400)
    create(:payments_subscription, :active, user: other_user, amount_in_cents: 500)

    expected = {
      subscription: {
        amount_in_cents: subscription.amount_in_cents
      }
    }
    assert_equal expected, AssembleActiveSubscription.(user)
  end
end
