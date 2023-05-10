require_relative '../test_base'

class Donations::Subscription::UpdateAmountTest < Donations::TestBase
  test "updates amount" do
    subscription = create :donations_subscription, amount_in_cents: 30

    Donations::Subscription::UpdateAmount.(subscription, 500)

    assert_equal 500, subscription.amount_in_cents
  end

  test "triggers insiders_status update" do
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, user:, amount_in_cents: 30

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).at_least_once

    Donations::Subscription::UpdateAmount.(subscription, 500)
  end
end
