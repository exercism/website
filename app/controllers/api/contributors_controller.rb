module API
  class ContributorsController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user

    def index
      render json: ProcessContributors.(params)
    end
  end
end
