class API::Settings::UserPreferencesController < API::BaseController
  def update
    render json: {}, status: :ok if current_user.preferences.update(user_preferences_params)
  end

  private
  def user_preferences_params
    params.
      require(:user_preferences).
      permit(*User::Preferences.keys).tap do |ps|
      # TODO: Add a test for this
      ps[:theme] = "light" if ps[:theme] == "dark" && !current_user.premium?
    end
  end
end
