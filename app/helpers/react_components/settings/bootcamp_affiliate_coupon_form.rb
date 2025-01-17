module ReactComponents
  module Settings
    class BootcampAffiliateCouponForm < ReactComponent
      initialize_with :context
      def to_s
        super("settings-bootcamp-affiliate-coupon-form", {
          insiders_status: current_user.insiders_status,
          bootcamp_affiliate_coupon_code: current_user.bootcamp_affiliate_coupon_code,
          context:,
          links: {
            insiders_path: Exercism::Routes.insiders_path,
            bootcamp_affiliate_coupon_code: Exercism::Routes.bootcamp_affiliate_coupon_code_api_settings_user_preferences_url
          }
        })
      end
    end
  end
end
