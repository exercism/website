class Admin::TrackMaintainersController < Admin::BaseController
  def index
    @track_maintainers_status = Track::RetrieveMaintainersStatus.()
  end

  def create
    Rails.cache.delete Track::RetrieveMaintainersStatus::CACHE_KEY
    redirect_to admin_track_maintainers_path
  end
end
