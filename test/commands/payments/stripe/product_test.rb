require_relative '../test_base'

class Payments::Stripe::ProductTest < Payments::TestBase
  test "identifies donation product" do
    price = RecursiveOpenStruct.new(product: 'DONATION_PRODUCT_ID')
    assert_equal :donation, Payments::Stripe::Product.from_price(price)
  end

  test "identifies premium product" do
    price = RecursiveOpenStruct.new(product: 'PREMIUM_PRODUCT_ID')
    assert_equal :premium, Payments::Stripe::Product.from_price(price)
  end

  test "raises for unknown product" do
    price_with_unknown_product = RecursiveOpenStruct.new(product: 'UNKNOWN')

    assert_raises Payments::Stripe::Product::UnknownStripeProductError do
      Payments::Stripe::Product.from_price(price_with_unknown_product)
    end
  end
end
