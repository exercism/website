module API
  class V1::PingController < BaseController
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
end
