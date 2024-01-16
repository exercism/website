require "test_helper"

class Payments::SubscriptionTest < ActiveSupport::TestCase
  test "status: uses symbols" do
    subscription = create :payments_subscription, :active
    subscription.update(status: :overdue)
    assert_equal :overdue, subscription.status
  end

  test "provider: uses symbols" do
    subscription = create :payments_subscription, :github
    subscription.update(provider: :stripe)
    assert_equal :stripe, subscription.provider
  end

  test "interval: uses symbols" do
    subscription = create :payments_subscription, :github
    subscription.update(interval: :year)
    assert_equal :year, subscription.interval
  end

  test "payments" do
    subscription = create :payments_subscription
    payment_1 = create(:payments_payment, subscription:)
    payment_2 = create(:payments_payment, subscription:)
    create :payments_payment

    assert_equal [payment_1, payment_2], subscription.payments.order(:id)
  end

  test "last_payment" do
    subscription = create :payments_subscription
    create(:payments_payment, subscription:)
    create(:payments_payment, subscription:)
    payment = create(:payments_payment, subscription:)

    assert_equal payment, subscription.last_payment
  end
end
