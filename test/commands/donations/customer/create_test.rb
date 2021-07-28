require_relative '../test_base'

class Donations::Customer::CreateTest < Donations::TestBase
  test "creates correctly" do
    user = create :user
    customer_id = SecureRandom.uuid

    Stripe::Customer.expects(:create).returns(mock_stripe_customer(customer_id)).at_least_once

    actual_id = Donations::Customer::Create.(user)

    assert_equal customer_id, actual_id
    assert_equal customer_id, user.stripe_customer_id
  end

  test "idempotent" do
    user = create :user
    customer_id = SecureRandom.uuid

    Stripe::Customer.expects(:create).returns(mock_stripe_customer(customer_id)).at_least_once

    id_1 = Donations::Customer::Create.(user)
    id_2 = Donations::Customer::Create.(user)

    assert_equal id_1, id_2
  end
end
