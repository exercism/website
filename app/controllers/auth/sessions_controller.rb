module Auth
  class SessionsController < Devise::SessionsController
    skip_before_action :authenticate_user!

    def create
      super
    rescue BCrypt::Errors::InvalidHash
      set_flash_message(:auth_alert, :invalid_hash) if is_navigational_format?

      redirect_to new_user_session_path
    end
  end
end
