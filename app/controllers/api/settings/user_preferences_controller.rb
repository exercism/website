module API
  module Settings
    class UserPreferencesController < BaseController
      def update
        render json: {}, status: :ok if current_user.preferences.update(user_preferences_params)
      end

      private
      def user_preferences_params
        params.
          require(:user_preferences).
          permit(*User::Preferences.keys)
      end
    end
  end
end
