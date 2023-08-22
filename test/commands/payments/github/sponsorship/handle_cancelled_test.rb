require_relative '../../test_base'

class Payments::Github::Sponsorship::HandleCancelledTest < Payments::TestBase
  test "cancels subscription if not a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = false
    user = create :user
    subscription = create :payments_subscription, :github, user:, external_id: sponsorship_node_id

    Payments::Github::Sponsorship::HandleCancelled.(user, sponsorship_node_id, is_one_time)

    assert_equal :canceled, subscription.reload.status
  end

  test "raises if subscription could not be found" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = false
    user = create :user

    assert_raises do
      Payments::Github::Sponsorship::HandleCancelled.(user, sponsorship_node_id, is_one_time)
    end
  end
end
