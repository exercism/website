class Maintaining::TrackMaintainersController < Maintaining::BaseController
  def index
    @track_maintainers_status = Track::RetrieveMaintainersStatus.()
  end
end
