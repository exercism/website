class API::FavoritesController < API::BaseController
  def index
    render json: {
      favorites: AssembleFavorites.(current_user, params)
    }
  end
end
