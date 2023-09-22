class API::ContributorsController < API::BaseController
  skip_before_action :authenticate_user!
  before_action :authenticate_user

  def index
    render json: AssembleContributors.(params)
  end
end
