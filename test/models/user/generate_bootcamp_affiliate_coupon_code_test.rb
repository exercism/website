require "test_helper"

class User::GenerateBootcampAffiliateCouponCodeTest < ActiveSupport::TestCase
  test "creates correctly" do
    user = create :user
    code = SecureRandom.hex(6)
    Stripe::PromotionCode.expects(:create).with(
      coupon: "NRp5SOVV", metadata: { user_id: user.id }
    ).returns(OpenStruct.new(code:))

    assert_equal code, User::GenerateBootcampAffiliateCouponCode.(user)
    assert_equal code, user.bootcamp_affiliate_coupon_code
  end

  test "immutable" do
    code = SecureRandom.hex(6)
    user = create :user, bootcamp_affiliate_coupon_code: code
    Stripe::PromotionCode.expects(:create).never

    assert_equal code, User::GenerateBootcampAffiliateCouponCode.(user)
    assert_equal code, user.bootcamp_affiliate_coupon_code
  end
end
