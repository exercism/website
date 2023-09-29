class API::Profiles::SolutionsController < API::Profiles::BaseController
  def index
    render json: AssembleProfileSolutionsList.(@user, list_params)
  end

  private
  def list_params
    params.permit(AssembleProfileSolutionsList.keys)
  end
end
