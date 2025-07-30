class FavoritesController < ApplicationController
  def index; end

  def create
    solution = Solution.find_by(uuid: params[:uuid])
    Favorite::Create.(current_user, solution)
  end

  def destroy; end
end
