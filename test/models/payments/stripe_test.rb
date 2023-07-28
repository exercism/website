require "test_helper"

class Payments::StripeTest < ActiveSupport::TestCase
  test "identifies donation product" do
    product_id = Exercism.secrets.stripe_recurring_product_id
    assert_equal :donation, Payments::Stripe.product_from_id(product_id)
  end

  test "identifies premium product" do
    product_id = Exercism.secrets.stripe_premium_product_id
    assert_equal :premium, Payments::Stripe.product_from_id(product_id)
  end

  test "raises for unknown product" do
    unknown_product_id = SecureRandom.uuid

    assert_raises Payments::Stripe::UnknownStripeProductError do
      Payments::Stripe.product_from_id(unknown_product_id)
    end
  end
end
