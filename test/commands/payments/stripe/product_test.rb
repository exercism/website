require_relative '../test_base'

class Payments::Stripe::ProductTest < Payments::TestBase
  test "identifies donation product" do
    product_id = Exercism.secrets.stripe_recurring_product_id
    assert_equal :donation, Payments::Stripe::Product.from_product_id(product_id)
  end

  test "identifies premium product" do
    product_id = Exercism.secrets.stripe_premium_product_id
    assert_equal :premium, Payments::Stripe::Product.from_product_id(product_id)
  end

  test "raises for unknown product" do
    unknown_product_id = SecureRandom.uuid

    assert_raises Payments::Stripe::Product::UnknownStripeProductError do
      Payments::Stripe::Product.from_product_id(unknown_product_id)
    end
  end
end
