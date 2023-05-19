module ReactComponents
  module Premium
    class PriceOptions < ReactComponent
      def to_s
        super(
          "premium-price-options", {
            user_signed_in: user_signed_in?,
            captcha_required: !current_user || current_user.captcha_required?,
            recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key)
          }
        )
      end
    end
  end
end
