class Maintaining::TrackCategoriesController < Maintaining::BaseController
  def index
    @track_categories = Track::RetrieveCategories.()
  end
end
