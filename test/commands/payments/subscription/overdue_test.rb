require_relative '../test_base'

class Payments::Subscription::OverdueTest < Payments::TestBase
  test "marks subscription as overdue" do
    subscription_id = SecureRandom.uuid
    user = create :user
    subscription = create :payments_subscription, :active, user:, external_id: subscription_id

    Payments::Subscription::Overdue.(subscription)
    assert subscription.overdue?
  end

  test "triggers insiders_status update" do
    subscription_id = SecureRandom.uuid
    user = create :user
    subscription = create :payments_subscription, :active, user:, external_id: subscription_id

    User::InsidersStatus::UpdateForPayment.expects(:call).with(user).at_least_once

    Payments::Subscription::Overdue.(subscription)
  end
end
