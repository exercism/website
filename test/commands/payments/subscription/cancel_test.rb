require_relative '../test_base'

class Payments::Subscription::CancelTest < Payments::TestBase
  test "cancels subscription" do
    subscription_id = SecureRandom.uuid
    user = create :user
    subscription = create :payments_subscription, :active, user:, external_id: subscription_id

    Payments::Subscription::Cancel.(subscription)
    assert subscription.canceled?
  end

  test "updates insiders status" do
    user = create :user
    subscription = create(:payments_subscription, user:)

    User::InsidersStatus::Update.expects(:defer).with(user).once

    Payments::Subscription::Cancel.(subscription)
  end
end
