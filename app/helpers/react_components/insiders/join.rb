module ReactComponents
  module Insiders
    class Join < ReactComponent
      initialize_with :return_to

      def to_s
        super("insiders-join", {
          captcha_required: current_user.captcha_required?,
          recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key),
          links: {
            return_to: return_to || Exercism::Routes.insiders_path,
            payment_pending: Exercism::Routes.payment_pending_insiders_url(return_to:)
          }
        })
      end
    end
  end
end
