module API
  class UsersController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user

    def update
      current_user.update!(user_params)

      render json: {
        user: {
          avatar_url: current_user.avatar_url
        }
      }
    end

    private
    def user_params
      params.require(:user).permit(:avatar)
    end
  end
end
