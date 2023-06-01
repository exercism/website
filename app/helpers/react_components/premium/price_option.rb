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
            insiders_redirect_link: Exercism::Routes.insiders_path
          }.merge(send("data_for_#{type}"))
        )
      end

      def data_for_monthly
        {
          period: 'month',
          display_amount: Premium::MONTH_AMOUNT_IN_DOLLARS,
          payment_intent_type: 'premium_monthly_subscription',
          paypal_link: 'https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-0EU999217Y297052UMRTXYEQ'
        }
      end

      def data_for_yearly
        {
          period: 'year',
          display_amount: Premium::YEAR_AMOUNT_IN_DOLLARS,
          payment_intent_type: 'premium_yearly_subscription',
          paypal_link: 'https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-23J11871PJ838224HMRTXYTA'
        }
      end

      def data_for_lifetime
        {
          period: 'lifetime',
          display_amount: Premium::LIFETIME_AMOUNT_IN_DOLLARS.to_i,
          payment_intent_type: 'payment',
          paypal_link: 'https://www.paypal.com/donate/?hosted_button_id=W898BNJR5JPDJ'
        }
      end
    end
  end
end
