module Auth
  class ConfirmationsController < Devise::ConfirmationsController
    def required; end

    def after_resending_confirmation_instructions_path_for(_resource_or_scope)
      user_signed_in? ? settings_path : new_user_session_path
    end
  end
end
