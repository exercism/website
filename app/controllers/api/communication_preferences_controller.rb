module API
  class CommunicationPreferencesController < BaseController
    def update
      render json: {}, status: :ok if current_user.communication_preferences.update(communication_preferences_params)
    end

    private
    def communication_preferences_params
      params.
        require(:communication_preferences).
        permit(:email_on_mentor_started_discussion_notification)
    end
  end
end
