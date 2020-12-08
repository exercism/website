module Auth
  class SessionsController < Devise::SessionsController
    skip_before_action :authenticate_user!
    skip_before_action :ensure_onboarded!
    before_action :disable_site_header!

    def create
      super
    rescue BCrypt::Errors::InvalidHash
      set_flash_message(:alert, :invalid_hash) if is_navigational_format?

      redirect_to new_user_session_path
    end
  end
end
