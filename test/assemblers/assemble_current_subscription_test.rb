require "test_helper"

class AssembleCurrentSubscriptionTest < ActiveSupport::TestCase
  test "serialize last active subscription" do
    user = create :user
    other_user = create :user
    create(:payments_subscription, :active, user:, amount_in_cents: 100)
    active_subscription = create(:payments_subscription, :active, :paypal, user:, amount_in_cents: 200, interval: :month)
    create(:payments_subscription, :canceled, user:, amount_in_cents: 300)
    create(:payments_subscription, :active, user: other_user, amount_in_cents: 500)

    expected = {
      subscription: {
        provider: :paypal,
        interval: :month,
        amount_in_cents: active_subscription.amount_in_cents
      }
    }
    assert_equal expected, AssembleCurrentSubscription.(user)
  end

  test "serialize last overdue subscription" do
    user = create :user
    other_user = create :user
    create(:payments_subscription, :active, user:, amount_in_cents: 100)
    overdue_subscription = create(:payments_subscription, :overdue, :paypal, user:, amount_in_cents: 200, interval: :month)
    create(:payments_subscription, :canceled, user:, amount_in_cents: 300)
    create(:payments_subscription, :overdue, user: other_user, amount_in_cents: 500)

    expected = {
      subscription: {
        provider: :paypal,
        interval: :month,
        amount_in_cents: overdue_subscription.amount_in_cents
      }
    }
    assert_equal expected, AssembleCurrentSubscription.(user)
  end

  test "gracefully handle no active or overdue subscription being present" do
    user = create :user
    other_user = create :user
    create(:payments_subscription, :canceled, user:)
    create(:payments_subscription, :overdue, user: other_user)
    create(:payments_subscription, :active, user: other_user)

    expected = { subscription: nil }
    assert_equal expected, AssembleCurrentSubscription.(user)
  end

  test "gracefully handle no subscriptions being present" do
    user = create :user

    expected = { subscription: nil }
    assert_equal expected, AssembleCurrentSubscription.(user)
  end

  test "gracefully handle no user being nil" do
    user = nil

    expected = { subscription: nil }
    assert_equal expected, AssembleCurrentSubscription.(user)
  end
end
