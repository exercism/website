module API
  class ValidateTokenController < BaseController
    def index
      render json: {
        status: {
          token: 'valid'
        }
      }, status: :ok
    end
  end
end
