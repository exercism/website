module API
  class UsersController < BaseController
    def show
      render json: {
        user: {
          handle: current_user.handle,
          insiders_status: current_user.insiders_status
        }
      }
    end

    def update
      current_user.update!(user_params)

      render json: {
        user: {
          handle: current_user.handle,
          avatar_url: current_user.avatar_url,
          has_avatar: current_user.has_avatar?
        }
      }
    end

    private
    def user_params
      params.require(:user).permit(:avatar)
    end
  end
end
