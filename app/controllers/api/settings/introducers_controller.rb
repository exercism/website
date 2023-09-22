class API::Settings::IntroducersController < API::BaseController
  def hide
    current_user.dismiss_introducer!(params[:slug])

    render json: {}
  end
end
