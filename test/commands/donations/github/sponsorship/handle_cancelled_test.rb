require_relative '../../test_base'

class Donations::Github::Sponsorship::HandleCancelledTest < Donations::TestBase
  test "cancels subscription if not a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = false
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, user:, external_id: sponsorship_node_id, provider: :github

    Donations::Github::Sponsorship::HandleCancelled.(user, sponsorship_node_id, is_one_time, 300)

    assert_equal :canceled, subscription.status
    refute user.active_donation_subscription?
  end

  test "raises if subscription could not be found" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = false
    user = create :user, active_donation_subscription: true

    assert_raises do
      Donations::Github::Sponsorship::HandleCancelled.(user, sponsorship_node_id, is_one_time, 300)
    end
  end

  test "does not change user if a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = true
    user = create :user, active_donation_subscription: true

    Donations::Github::Sponsorship::HandleCancelled.(user, sponsorship_node_id, is_one_time, 300)

    assert user.active_donation_subscription?
  end
end
