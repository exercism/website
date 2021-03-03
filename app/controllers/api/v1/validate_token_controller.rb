module API
  class V1::ValidateTokenController < BaseController
    def index
      render json: {
        status: {
          token: 'valid'
        }
      }, status: :ok
    end
  end
end
