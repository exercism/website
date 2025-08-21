class Maintaining::TrackCategoriesController < Maintaining::BaseController
  def index
    @track_categories = Track::RetrieveCategories.()
  end

  def create
    Rails.cache.delete Track::RetrieveCategories::CACHE_KEY
    redirect_to maintaining_track_categories_path
  end
end
