class API::SettingsController < API::BaseController
  def update
    cmd = User::Update.(current_user, params)

    cmd.on_success { render json: {} }
    cmd.on_failure { |ers| render_400(:failed_validations, errors: ers) }
  end

  def sudo_update
    unless current_user.valid_password?(params.dig(:user, :sudo_password))
      Rails.logger.debug "Wrong password"

      return render_400(:incorrect_password)
    end

    if params.dig(:user, :password).present?
      user_params = params[:user]
      unless user_params[:password] == user_params[:password_confirmation]
        Rails.logger.debug "Wrong password"

        return render_400(:passwords_dont_match)
      end
    end

    permitted = params.
      require(:user).
      permit(:handle, :email, :password, :password_confirmation)

    render json: {}, status: :ok if current_user.update(permitted)
  end
end
