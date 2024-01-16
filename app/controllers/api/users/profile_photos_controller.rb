class API::Users::ProfilePhotosController < API::BaseController
  def destroy
    current_user.update!(avatar_url: nil)
    current_user.avatar.purge

    render json: {
      user: {
        handle: current_user.handle,
        avatar_url: current_user.avatar_url,
        has_avatar: current_user.has_avatar?
      }
    }
  end
end
