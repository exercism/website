class API::GenerateBootcampAffiliateCouponCode < API::BaseController
  skip_before_action :authenticate_user!
  before_action :authenticate_user

  def create
    return unless current_user.insider?
    return if current_user.bootcamp_affiliate_coupon_code.present?

    User::GenerateBootcampAffiliateCouponCode.(current_user)

    render json: { coupon_code: current_user.bootcamp_affiliate_coupon_code }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
