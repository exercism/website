module API
  module Users
    class ProfilePhotosController < BaseController
      def destroy
        current_user.avatar.purge

        render json: {
          user: {
            handle: current_user.handle,
            avatar_url: current_user.avatar_url,
            is_avatar_attached: current_user.avatar.attached?
          }
        }
      end
    end
  end
end
