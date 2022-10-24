module API
  class CommunityStoriesController < BaseController
    def index
      render json: AssembleCommunityStories.(params)
    end
  end
end
