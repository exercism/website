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
            premium_redirect_link: Exercism::Routes.premium_index_path
          }.merge(send("data_for_#{type}"))
        )
      end

      def data_for_monthly
        {
          period: 'month',
          display_amount: 9.99,
          payment_intent_type: 'premium_monthly_subscription',
          paypal_link: 'https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-23J11871PJ838224HMRTXYTA'
        }
      end

      def data_for_yearly
        {
          period: 'year',
          display_amount: 99.99,
          payment_intent_type: 'premium_yearly_subscription',
          paypal_link: 'https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-23J11871PJ838224HMRTXYTA'
        }
      end

      def data_for_lifetime
        {
          period: 'lifetime',
          display_amount: 499,
          payment_intent_type: 'payment',
          paypal_link: 'https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-79144942EH3169155MRTX2NI'
        }
      end
    end
  end
end
