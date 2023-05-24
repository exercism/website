require "test_helper"

class AssembleActiveSubscriptionTest < ActiveSupport::TestCase
  test "serialize last active subscription" do
    user = create :user
    other_user = create :user
    create(:payments_subscription, :active, user:, amount_in_cents: 100)
    subscription = create(:payments_subscription, :active, :donation, :paypal, user:, amount_in_cents: 200)
    create(:payments_subscription, :canceled, user:, amount_in_cents: 300)
    create(:payments_subscription, :overdue, user:, amount_in_cents: 400)
    create(:payments_subscription, :active, user: other_user, amount_in_cents: 500)

    expected = {
      subscription: {
        product: :donation,
        provider: :paypal,
        amount_in_cents: subscription.amount_in_cents
      }
    }
    assert_equal expected, AssembleActiveSubscription.(user)
  end

  test "gracefully handle no active subscription being present" do
    user = create :user
    other_user = create :user
    create(:payments_subscription, :canceled, user:)
    create(:payments_subscription, :overdue, user:)
    create(:payments_subscription, :active, user: other_user)

    expected = { subscription: nil }
    assert_equal expected, AssembleActiveSubscription.(user)
  end

  test "gracefully handle no subscriptions being present" do
    user = create :user

    expected = { subscription: nil }
    assert_equal expected, AssembleActiveSubscription.(user)
  end

  test "gracefully handle no user being nil" do
    user = nil

    expected = { subscription: nil }
    assert_equal expected, AssembleActiveSubscription.(user)
  end
end
