require_relative '../test_base'

class Donations::Subscription::CancelTest < Donations::TestBase
  test "cancels subscription" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, active: true, user:, external_id: subscription_id

    Donations::Subscription::Cancel.(subscription)
    assert_equal :canceled, subscription.status
    refute user.active_donation_subscription?
  end

  test "triggers insiders_status update" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, active: true, user:, external_id: subscription_id

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).at_least_once

    Donations::Subscription::Cancel.(subscription)
  end
end
