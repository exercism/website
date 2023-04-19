require_relative '../../test_base'

class Donations::Stripe::Customer::CreateForEmailTest < Donations::TestBase
  test "creates correctly" do
    email = "#{SecureRandom.uuid}@bar.com"
    customer_id = SecureRandom.uuid

    Stripe::Customer.expects(:create).returns(mock_stripe_customer(customer_id)).at_least_once
    Stripe::Customer.expects(:list).returns(mock(data: []))

    actual_id = Donations::Stripe::Customer::CreateForEmail.(email)

    assert_equal customer_id, actual_id
  end

  test "looks up existing customer" do
    email = "#{SecureRandom.uuid}@bar.com"
    customer_id = SecureRandom.uuid

    resp = mock(data: [mock(id: customer_id)])
    Stripe::Customer.expects(:list).with(email:, limit: 1).returns(resp)
    Stripe::Customer.expects(:create).never

    actual = Donations::Stripe::Customer::CreateForEmail.(email)

    assert_equal customer_id, actual
  end
end
