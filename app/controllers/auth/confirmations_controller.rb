module Auth
  class ConfirmationsController < Devise::ConfirmationsController
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_csrf_failure

    def required; end

    def after_resending_confirmation_instructions_path_for(_resource_or_scope)
      user_signed_in? ? settings_path : new_user_session_path
    end

    private
    def handle_csrf_failure
      set_flash_message(:alert, :csrf_failure) if is_navigational_format?
      redirect_to new_user_session_path
    end
  end
end
