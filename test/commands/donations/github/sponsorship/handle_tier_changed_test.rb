require_relative '../../test_base'

class Donations::Github::Sponsorship::HandleTierChangedTest < Donations::TestBase
  test "updates subscription if not a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = false
    amount = 300
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, user:, provider: :github,
      external_id: sponsorship_node_id, amount_in_cents: 500

    Donations::Github::Sponsorship::HandleTierChanged.(user, sponsorship_node_id, is_one_time, amount)

    assert_equal amount, subscription.reload.amount_in_cents
  end

  test "does not update a subscription if a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = true
    amount = 300
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, user:, provider: :github,
      external_id: sponsorship_node_id, amount_in_cents: 500

    Donations::Github::Sponsorship::HandleTierChanged.(user, sponsorship_node_id, is_one_time, amount)

    assert_equal 500, subscription.reload.amount_in_cents
  end
end
