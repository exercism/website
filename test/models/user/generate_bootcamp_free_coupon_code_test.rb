require "test_helper"

class User::GenerateBootcampFreeCouponCodeTest < ActiveSupport::TestCase
  test "creates correctly" do
    user = create :user
    code = SecureRandom.hex(6)
    Stripe::PromotionCode.expects(:create).with(
      coupon: "OarhoKrd",
      max_redemptions: 1,
      metadata: { user_id: user.id }
    ).returns(OpenStruct.new(code:))

    User::GenerateBootcampFreeCouponCode.(user)

    assert_equal code, user.bootcamp_free_coupon_code
  end

  test "immutable" do
    code = SecureRandom.hex(6)
    user = create :user, bootcamp_free_coupon_code: code
    Stripe::PromotionCode.expects(:create).never

    User::GenerateBootcampFreeCouponCode.(user)

    assert_equal code, user.bootcamp_free_coupon_code
  end
end
