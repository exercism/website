module API
  class ProfilesController < BaseController
    before_action :authenticate_user!

    def destroy
      current_user.profile.destroy

      render json: {}
    end
  end
end
