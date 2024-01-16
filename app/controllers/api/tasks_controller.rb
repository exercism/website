class API::TasksController < API::BaseController
  skip_before_action :authenticate_user!
  before_action :authenticate_user

  def index
    render json: AssembleTasks.(params)
  end
end
