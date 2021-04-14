module API
  class Profiles::BaseController < API::BaseController
    before_action :use_user

    private
    def use_user
      @user = User.find_by(handle: params[:profile_id])
      @profile = @user&.profile

      render_404(:profile_not_found) unless @profile
    end
  end
end
