require_relative '../../test_base'

class Payments::Paypal::Customer::FindOrUpdateTest < Payments::TestBase
  test "returns existing user with matching paypal payer id" do
    email = "#{SecureRandom.uuid}@bar.com"
    paypal_payer_id = SecureRandom.uuid
    user = create(:user, paypal_payer_id:, email:)

    found_user = Payments::Paypal::Customer::FindOrUpdate.(paypal_payer_id, email)

    assert_equal user, found_user
  end

  test "updates existing user with matching user id" do
    paypal_payer_id = SecureRandom.uuid

    user = create(:user)

    found_user = Payments::Paypal::Customer::FindOrUpdate.(paypal_payer_id, nil, user_id: user.id)

    assert_equal user, found_user
    assert_equal paypal_payer_id, found_user.paypal_payer_id
  end

  test "updates existing user with matching paypal subscription id" do
    paypal_payer_id = SecureRandom.uuid

    user = create :user
    subscription = create(:payments_subscription, :paypal, user:)

    found_user = Payments::Paypal::Customer::FindOrUpdate.(paypal_payer_id, nil, paypal_subscription_id: subscription.external_id)

    assert_equal user, found_user
    assert_equal paypal_payer_id, found_user.paypal_payer_id
  end

  test "updates existing user with matching paypal email" do
    email = "#{SecureRandom.uuid}@bar.com"
    paypal_payer_id = SecureRandom.uuid

    user = create(:user, email:)

    found_user = Payments::Paypal::Customer::FindOrUpdate.(paypal_payer_id, email)

    assert_equal user, found_user
    assert_equal paypal_payer_id, found_user.paypal_payer_id
  end

  test "returns nil when no user with matching user email, paypal email or paypal payer id could be found" do
    email = "#{SecureRandom.uuid}@bar.com"
    paypal_payer_id = SecureRandom.uuid

    user = Payments::Paypal::Customer::FindOrUpdate.(paypal_payer_id, email)

    assert_nil user
  end
end
