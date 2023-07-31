require_relative '../test_base'

class Payments::Subscription::UpdateAmountTest < Payments::TestBase
  %i[premium donation].each do |product|
    test "updates amount for #{product} subscription" do
      subscription = create :payments_subscription, product, amount_in_cents: 30

      Payments::Subscription::UpdateAmount.(subscription, 500)

      assert_equal 500, subscription.amount_in_cents
    end

    test "triggers insiders_status update for #{product} subscription" do
      user = create :user, active_donation_subscription: true
      subscription = create :payments_subscription, product, user:, amount_in_cents: 30

      User::InsidersStatus::TriggerUpdate.expects(:call).with(user).at_least_once

      Payments::Subscription::UpdateAmount.(subscription, 500)
    end
  end

  test "updates premium for premium subscription" do
    subscription = create :payments_subscription, :premium, amount_in_cents: 30

    User::Premium::Update.expects(:call).with(subscription.user)

    Payments::Subscription::UpdateAmount.(subscription, 500)
  end

  test "does not update premium for donation subscription" do
    subscription = create :payments_subscription, :donation, amount_in_cents: 30

    User::Premium::Update.expects(:call).with(subscription.user).never

    Payments::Subscription::UpdateAmount.(subscription, 500)
  end
end
