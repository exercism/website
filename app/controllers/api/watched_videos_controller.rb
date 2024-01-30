class API::WatchedVideosController < API::BaseController
  def create
    User::WatchedVideo::Create.(current_user, params[:video_provider], params[:video_id])

    render json: {}
  end
end
