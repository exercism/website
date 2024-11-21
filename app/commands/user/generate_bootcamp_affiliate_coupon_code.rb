class User::GenerateBootcampAffiliateCouponCode
  include Mandate

  initialize_with :user

  def call
    # Easy cheap guard
    return user_data.bootcamp_affiliate_coupon_code if user_data.bootcamp_affiliate_coupon_code.present?

    # Now things get expensive with Stripe call and lock below
    generate_coupon_code.tap do |code|
      user_data.with_lock do
        return if user_data.bootcamp_affiliate_coupon_code.present? # rubocop:disable Lint/NonLocalExitFromIterator

        user_data.update!(bootcamp_affiliate_coupon_code: code)
      end
    end
  end

  private
  delegate :data, to: :user, prefix: true

  memoize
  def generate_coupon_code
    promo_code = Stripe::PromotionCode.create(
      coupon: COUPON_ID,
      metadata: {
        user_id: user.id
      }
    )
    promo_code.code
  end

  COUPON_ID = "NRp5SOVV".freeze
end
