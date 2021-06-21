class SettingsController < ApplicationController
  def api; end

  # TODO: Move this to API
  def reset_api_token
    current_user.create_auth_token!
    redirect_to action: :api
  end

  def update
    permitted = params.require(:user).permit(
      :name, :location, :bio, pronouns: []
    )
    current_user.update(permitted)
    redirect_to action: :show
  end
end
