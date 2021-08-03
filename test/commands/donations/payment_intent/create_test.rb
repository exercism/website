require_relative '../test_base'

class Donations::PaymentIntent::CreateTest < Donations::TestBase
  test "proxies for subscription" do
    customer_id = SecureRandom.uuid
    amount = 10
    user = create :user, stripe_customer_id: customer_id

    Donations::Customer::Create.expects(:call).with(user).returns(customer_id)
    Donations::PaymentIntent::CreateForSubscription.expects(:call).with(
      customer_id, amount
    )
    Donations::PaymentIntent::Create.(user, :subscription, amount)
  end

  test "proxies for payment" do
    customer_id = SecureRandom.uuid
    amount = 10
    user = create :user, stripe_customer_id: customer_id

    Donations::Customer::Create.expects(:call).with(user).returns(customer_id)
    Donations::PaymentIntent::CreateForPayment.expects(:call).with(
      customer_id, amount
    )
    Donations::PaymentIntent::Create.(user, :random_shizzle, amount)
  end
end
