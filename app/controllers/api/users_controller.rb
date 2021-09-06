module API
  class UsersController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user

    def update
      current_user.update!(user_params)

      render json: {
        user: {
          handle: current_user.handle,
          avatar_url: current_user.avatar_url,
          is_avatar_attached: current_user.avatar.attached?
        }
      }
    end

    private
    def user_params
      params.require(:user).permit(:avatar)
    end
  end
end
