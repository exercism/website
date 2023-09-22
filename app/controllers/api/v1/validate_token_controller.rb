class API::V1::ValidateTokenController < API::BaseController
  def index
    render json: {
      status: {
        token: 'valid'
      }
    }, status: :ok
  end
end
