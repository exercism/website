class API::Profiles::BaseController < API::BaseController
  before_action :use_user
  skip_before_action :authenticate_user!

  private
  def use_user
    @user = User.find_by(handle: params[:profile_handle])
    @profile = @user&.profile

    render_404(:profile_not_found) unless @profile
  end
end
