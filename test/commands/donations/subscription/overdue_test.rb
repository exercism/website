require_relative '../test_base'

class Donations::Subscription::OverdueTest < Donations::TestBase
  test "marks subscription as overdue" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, status: :active, user:, external_id: subscription_id

    Donations::Subscription::OverdueTest.(subscription)
    assert subscription.overdue?
    refute user.active_donation_subscription?
  end

  test "triggers insiders_status update" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, status: :active, user:, external_id: subscription_id

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).at_least_once

    Donations::Subscription::OverdueTest.(subscription)
  end
end
