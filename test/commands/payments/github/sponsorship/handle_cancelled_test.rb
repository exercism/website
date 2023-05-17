require_relative '../../test_base'

class Payments::Github::Sponsorship::HandleCancelledTest < Payments::TestBase
  test "cancels subscription if not a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = false
    user = create :user, active_donation_subscription: true
    subscription = create :payments_subscription, user:, external_id: sponsorship_node_id, provider: :github

    Payments::Github::Sponsorship::HandleCancelled.(user, sponsorship_node_id, is_one_time)

    assert_equal :canceled, subscription.reload.status
    refute user.reload.active_donation_subscription?
  end

  test "raises if subscription could not be found" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = false
    user = create :user, active_donation_subscription: true

    assert_raises do
      Payments::Github::Sponsorship::HandleCancelled.(user, sponsorship_node_id, is_one_time)
    end
  end

  test "does not change user if a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = true
    user = create :user, active_donation_subscription: true

    Payments::Github::Sponsorship::HandleCancelled.(user, sponsorship_node_id, is_one_time)

    assert user.active_donation_subscription?
  end
end
