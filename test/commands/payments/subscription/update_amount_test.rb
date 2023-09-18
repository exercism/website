require_relative '../test_base'

class Payments::Subscription::UpdateAmountTest < Payments::TestBase
  test "updates amount" do
    subscription = create :payments_subscription, amount_in_cents: 30

    Payments::Subscription::UpdateAmount.(subscription, 500)

    assert_equal 500, subscription.amount_in_cents
  end

  test "triggers insiders_status update" do
    user = create :user
    subscription = create :payments_subscription, user:, amount_in_cents: 30

    User::InsidersStatus::UpdateForPayment.expects(:call).with(user) # .at_least_once

    Payments::Subscription::UpdateAmount.(subscription, 500)
  end
end
