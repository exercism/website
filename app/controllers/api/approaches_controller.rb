class API::ApproachesController < API::BaseController
  skip_before_action :authenticate_user!
  before_action :authenticate_user

  def index
    render json: AssembleApproaches.(params)
  end
end
