module API
  class ProfilesController < BaseController
    def create
      if current_user.update(params[:user].permit(:name, :location, :bio))
        begin
          current_user.create_profile!
        rescue ActiveRecord::RecordNotUnique
          # Handle a double-click gracefully
        end

        render json: {
          links: {
            profile: Exercism::Routes.profile_url(current_user, first_time: true)
          }
        }
      else
        render json: {}, status: :unprocessable_entity
      end
    end

    def destroy
      current_user.profile.destroy

      render json: {}
    end
  end
end
