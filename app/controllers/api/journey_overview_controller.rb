module API
  class JourneyOverviewController < BaseController
    def show
      render json: AssembleJourneyOverview.(current_user)
    end
  end
end
