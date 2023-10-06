class API::Settings::CommunicationPreferencesController < API::BaseController
  def update
    render json: {}, status: :ok if current_user.communication_preferences.update(communication_preferences_params)
  end

  private
  memoize
  def communication_preferences_params
    params.
      require(:communication_preferences).
      permit(*User::CommunicationPreferences.keys)
  end
end
