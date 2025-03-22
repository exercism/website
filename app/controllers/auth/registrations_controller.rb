require "hcaptcha"

module Auth
  class RegistrationsController < Devise::RegistrationsController
    skip_before_action :authenticate_user!
    before_action :configure_permitted_parameters
    before_action :verify_captcha!, only: [:create]

    def create
      super do |user|
        if user.persisted?
          User::Bootstrap.(
            user,
            course_access_code: session[:course_access_code]
          )
        end
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[name handle])
    end

    def after_inactive_sign_up_path_for(_resource)
      auth_confirmation_required_path
    end

    private
    def verify_captcha!
      return true if Rails.env.development?

      verification = HCaptcha.verify(params["h-captcha-response"])
      return if verification.succeeded?

      set_flash_message(:alert, :captcha_verification_failed) if is_navigational_format?

      redirect_to new_user_registration_path
    end
  end
end
