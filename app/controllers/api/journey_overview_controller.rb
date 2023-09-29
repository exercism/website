class API::JourneyOverviewController < API::BaseController
  def show
    render json: AssembleJourneyOverview.(current_user)
  end
end
