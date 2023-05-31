require_relative '../test_base'

class Payments::Paypal::ProductTest < Payments::TestBase
  test "identifies donation product" do
    product_name = Exercism.secrets.paypal_donation_product_name
    assert_equal :donation, Payments::Paypal.product_from_name(product_name)
  end

  test "identifies premium product" do
    product_name = Exercism.secrets.paypal_premium_product_name
    assert_equal :premium, Payments::Paypal.product_from_name(product_name)
  end

  test "raises for unknown product" do
    unknown_product_name = SecureRandom.uuid

    assert_raises Payments::Paypal::UnknownPaypalProductError do
      Payments::Paypal.product_from_name(unknown_product_name)
    end
  end
end
