class RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_user!
  before_action :configure_permitted_parameters
  before_action :verify_captcha!, only: [:create]

  def create
    super { |user| User::Bootstrap.(user) if user.persisted? }
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name handle])
  end

  def after_inactive_sign_up_path_for(_resource)
    confirmation_required_path
  end

  private
  def verify_captcha!
    verification = HCaptcha.verify(params["h-captcha-response"])

    redirect_to new_user_registration_path, alert: "Captcha verification failed. Please try again." if verification.failed?
  end
end
