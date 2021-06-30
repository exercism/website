class SettingsController < ApplicationController
  def api_cli; end

  def communication_preferences; end

  def update
    permitted = params.require(:user).permit(
      :name, :location, :bio,
      pronoun_parts: {}
    )
    if current_user.update(permitted)
      # TODO: I can't get this to work
      flash.notice = "Your settings have been updated"
    end
    redirect_to action: :show
  end

  def sudo_update
    unless current_user.valid_password?(params.dig(:user, :sudo_password))
      # TODO: Handle this in the UI
      Rails.logger.debug "Wrong password"
      return redirect_to settings_path, alert: "Incorrect password"
    end

    if params.dig(:user, :password).present?
      user_params = params[:user]
      unless user_params[:password] == user_params[:password_confirmation]
        # TODO: Handle this in the UI
        Rails.logger.debug "Wrong password"
        return redirect_to settings_path, alert: "Passwords don't match"
      end
    end

    permitted = params.require(:user).permit(
      :handle, :email, :password, :password_confirmation
    )
    if current_user.update(permitted)
      # TODO: I can't get this to work
      flash.notice = "Your settings have been updated"
    end
    redirect_to action: :show
  end
end
