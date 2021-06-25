module API
  class SettingsController < BaseController
    def update
      permitted = params.require(:user).permit(
        :name, :location, :bio,
        pronoun_parts: []
      )

      if current_user.update(permitted)
        render json: {}, status: :ok
      else
        render_400(:failed_validations, errors: current_user.errors)
      end
    end
  end
end
