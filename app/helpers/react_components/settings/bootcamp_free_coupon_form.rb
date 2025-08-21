module ReactComponents
  module Settings
    class BootcampFreeCouponForm < ReactComponent
      def to_s
        super("settings-bootcamp-free-coupon-form", {
          insiders_status: current_user.insiders_status,
          bootcamp_free_coupon_code: current_user.bootcamp_free_coupon_code,
          links: {
            bootcamp_free_coupon_code: Exercism::Routes.bootcamp_free_coupon_code_api_settings_user_preferences_url
          }
        })
      end
    end
  end
end
