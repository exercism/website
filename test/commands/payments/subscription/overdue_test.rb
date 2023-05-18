require_relative '../test_base'

class Payments::Subscription::OverdueTest < Payments::TestBase
  test "marks subscription as overdue" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :payments_subscription, :active, user:, external_id: subscription_id

    Payments::Subscription::Overdue.(subscription)
    assert subscription.overdue?
    refute user.active_donation_subscription?
  end

  test "triggers insiders_status update" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :payments_subscription, :active, user:, external_id: subscription_id

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).at_least_once

    Payments::Subscription::Overdue.(subscription)
  end
end
