require_relative '../test_base'

class Payments::Subscription::CancelPendingTest < Payments::TestBase
  test "cancels pending subscriptions that have been open for 2 days" do
    old_pending_sub_1 = create :payments_subscription, :pending, created_at: Time.current - 7.days
    old_pending_sub_2 = create :payments_subscription, :pending, created_at: Time.current - 2.days
    new_pending_sub = create :payments_subscription, :pending, created_at: Time.current
    active_sub = create :payments_subscription, :active
    overdue_sub = create :payments_subscription, :overdue
    canceled_sub = create :payments_subscription, :canceled

    Payments::Subscription::CancelPending.()

    assert old_pending_sub_1.reload.canceled?
    assert old_pending_sub_2.reload.canceled?
    assert new_pending_sub.reload.pending?
    assert active_sub.reload.active?
    assert overdue_sub.reload.overdue?
    assert canceled_sub.reload.canceled?
  end
end
