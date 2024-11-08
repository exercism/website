class API::GenerateBootcampFreeCouponCode < API::BaseController
  skip_before_action :authenticate_user!
  before_action :authenticate_user

  def create
    return if current_user.insiders_status != :active_lifetime
    return if current_user.bootcamp_free_coupon_code.present?

    User::GenerateBootcampFreeCouponCode.(current_user)

    render json: { coupon_code: current_user.bootcamp_free_coupon_code }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
