module API
  class CommunityVideosController < BaseController
    def lookup
      video = CommunityVideo::Retrieve.(params[:video_url])
      render json: { community_video: video }.to_json
    end
  end
end
