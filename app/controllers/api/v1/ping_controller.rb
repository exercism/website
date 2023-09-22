class API::V1::PingController < API::BaseController
  skip_before_action :authenticate_user!

  def index
    render json: {
      status: {
        website: true,
        database: true
      }
    }, status: :ok
  end
end
