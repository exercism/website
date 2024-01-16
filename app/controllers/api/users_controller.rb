class API::UsersController < API::BaseController
  def show
    render json: {
      user: {
        handle: current_user.handle,
        insiders_status: current_user.insiders_status
      }
    }
  end

  def update
    User::UpdateAvatar.(current_user, params.require(:user)[:avatar])

    render json: {
      user: {
        handle: current_user.handle,
        avatar_url: current_user.avatar_url,
        has_avatar: current_user.has_avatar?
      }
    }
  end

  def activate_insiders
    User::InsidersStatus::Activate.(current_user)

    render json: {
      links: {
        redirect_url: insiders_url
      }
    }
  end
end
