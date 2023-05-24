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
end
