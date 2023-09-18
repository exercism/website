require_relative '../../test_base'

class Payments::Github::Sponsorship::HandleTierChangedTest < Payments::TestBase
  test "updates subscription if not a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = false
    amount = 300
    user = create :user
    subscription = create :payments_subscription, :github, user:,
      external_id: sponsorship_node_id, amount_in_cents: 500

    Payments::Github::Sponsorship::HandleTierChanged.(user, sponsorship_node_id, is_one_time, amount)

    assert_equal amount, subscription.reload.amount_in_cents
  end

  test "does not update a subscription if a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = true
    amount = 300
    user = create :user
    subscription = create :payments_subscription, :github, user:,
      external_id: sponsorship_node_id, amount_in_cents: 500

    Payments::Github::Sponsorship::HandleTierChanged.(user, sponsorship_node_id, is_one_time, amount)

    assert_equal 500, subscription.reload.amount_in_cents
  end
end
