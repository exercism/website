module ReactComponents
  module Premium
    class PriceOption < ReactComponent
      initialize_with :type

      def to_s
        super(
          "premium-price-option", {
            user_signed_in: user_signed_in?,
            captcha_required: !current_user || current_user.captcha_required?,
            recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key),
            premium_redirect_link: Exercism::Routes.premium_path,
            premium_redirect_url: Exercism::Routes.premium_url,
            insiders_redirect_link: Exercism::Routes.insiders_path
          }.merge(send("data_for_#{type}"))
        )
      end

      def data_for_monthly
        {
          period: 'month',
          display_amount: ::Premium::MONTH_AMOUNT_IN_DOLLARS,
          payment_intent_type: 'premium_monthly_subscription',
          paypal_link: Exercism::Routes.create_paypal_premium_api_payments_subscriptions_path(interval: :month)
        }
      end

      def data_for_yearly
        {
          period: 'year',
          display_amount: ::Premium::YEAR_AMOUNT_IN_DOLLARS,
          payment_intent_type: 'premium_yearly_subscription',
          paypal_link: Exercism::Routes.create_paypal_premium_api_payments_subscriptions_path(interval: :year)
        }
      end

      def data_for_lifetime
        {
          period: 'lifetime',
          display_amount: ::Premium::LIFETIME_AMOUNT_IN_DOLLARS.to_i,
          payment_intent_type: 'payment',
          paypal_link: "#{Exercism.config.paypal_url}/donate/?hosted_button_id=#{Exercism.secrets.paypal_lifetime_insiders_hosted_button_id}&custom=#{current_user&.id}" # rubocop:disable Layout/LineLength
        }
      end
    end
  end
end
