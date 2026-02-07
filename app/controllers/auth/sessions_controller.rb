module Auth
  class SessionsController < Devise::SessionsController
    skip_before_action :authenticate_user!
    skip_before_action :ensure_onboarded!
    before_action :store_referer!, only: [:new]

    include Devise::Controllers::Rememberable

    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_csrf_failure

    def create
      super do |user|
        remember_me(user)
      end
    rescue BCrypt::Errors::InvalidHash
      set_flash_message(:alert, :invalid_hash) if is_navigational_format?

      redirect_to new_user_session_path
    end

    def store_referer!
      return unless params[:auth_return_to].present?

      store_location_for(:user, params[:auth_return_to])
    end

    private
    def handle_csrf_failure
      set_flash_message(:alert, :csrf_failure) if is_navigational_format?
      redirect_to new_user_session_path
    end
  end
end
