class API::CommunityStoriesController < API::BaseController
  def index
    render json: AssembleCommunityStories.(params)
  end
end
