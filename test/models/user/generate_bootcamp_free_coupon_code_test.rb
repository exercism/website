require "test_helper"

class User::GenerateBootcampFreeCouponCodeTest < ActiveSupport::TestCase
  test "creates correctly" do
    user = create :user, :lifetime_insider
    code = SecureRandom.hex(6)
    Stripe::PromotionCode.expects(:create).with(
      coupon: "OarhoKrd",
      max_redemptions: 1,
      metadata: { user_id: user.id }
    ).returns(OpenStruct.new(code:))

    assert_equal code, User::GenerateBootcampFreeCouponCode.(user)
    assert_equal code, user.bootcamp_free_coupon_code
  end

  test "immutable" do
    code = SecureRandom.hex(6)
    user = create :user, :lifetime_insider, bootcamp_free_coupon_code: code
    Stripe::PromotionCode.expects(:create).never

    assert_equal code, User::GenerateBootcampFreeCouponCode.(user)
    assert_equal code, user.bootcamp_free_coupon_code
  end

  test "doesn't work for non-lifetime-insider" do
    user = create :user, :insider
    Stripe::PromotionCode.expects(:create).never

    assert_nil User::GenerateBootcampFreeCouponCode.(user)
    assert_nil user.bootcamp_free_coupon_code
  end

  test "doesn't work for non-insider" do
    user = create :user
    Stripe::PromotionCode.expects(:create).never

    assert_nil User::GenerateBootcampFreeCouponCode.(user)
    assert_nil user.bootcamp_free_coupon_code
  end
end
