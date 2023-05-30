module ReactComponents
  module Insiders
    class InsidersStatus < ReactComponent
      def to_s
        super(
          "insiders-status",
          {
            status: current_user.insiders_status,
            insiders_status_request: Exercism::Routes.api_user_url(current_user),
            activate_insider_link: Exercism::Routes.activate_insiders_api_user_path,
            user_signed_in: user_signed_in?,
            captcha_required: !current_user || current_user.captcha_required?,
            recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key),
            links: { insiders_path: Exercism::Routes.insiders_path, premium_redirect_link: Exercism::Routes.premium_path }
          }
        )
      end
    end
  end
end
