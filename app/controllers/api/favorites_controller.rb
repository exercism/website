class API::FavoritesController < API::BaseController
  def index
    render json: AssembleFavorites.(current_user, params)
  end
end
