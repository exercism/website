require_relative '../../test_base'

class Payments::Stripe::Customer::CreateForUserTest < Payments::TestBase
  test "creates correctly" do
    user = create :user
    customer_id = SecureRandom.uuid

    Stripe::Customer.expects(:create).
      with(email: user.email, metadata: { user_id: user.id }).
      returns(mock_stripe_customer(customer_id)).at_least_once

    actual_id = Payments::Stripe::Customer::CreateForUser.(user)

    assert_equal customer_id, actual_id
    assert_equal customer_id, user.stripe_customer_id
  end

  test "idempotent" do
    user = create :user
    customer_id = SecureRandom.uuid

    Stripe::Customer.expects(:retrieve).with(customer_id)
    Stripe::Customer.expects(:create).returns(mock_stripe_customer(customer_id))

    id_1 = Payments::Stripe::Customer::CreateForUser.(user)
    id_2 = Payments::Stripe::Customer::CreateForUser.(user)

    assert_equal id_1, id_2
  end
end
