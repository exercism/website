class API::ValidateTokenController < API::BaseController
  def index
    render json: {
      status: {
        token: 'valid'
      }
    }, status: :ok
  end
end
