class Maintaining::TrackMaintainersController < Maintaining::BaseController
  def index
    @track_maintainers_status = Track::RetrieveMaintainersStatus.()
  end

  def create
    Rails.cache.delete Track::RetrieveMaintainersStatus::CACHE_KEY
    redirect_to maintaining_track_maintainers_path
  end
end
