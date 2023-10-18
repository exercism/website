class API::TracksController < API::BaseController
  skip_before_action :authenticate_user!
  before_action :authenticate_user

  def index
    tracks = Track::Search.(
      criteria: params[:criteria],
      tags: params[:tags],
      status: params[:status],
      user: current_user
    )

    render json: {
      tracks: SerializeTracks.(tracks, current_user)
    }, status: :ok
  end

  def show
    begin
      track = Track.find_by!(slug: params[:slug])
    rescue StandardError
      return render_404(:track_not_found, fallback_url: tracks_url)
    end

    return render_404(:track_not_found, fallback_url: tracks_url) unless track.accessible_by?(current_user)

    render json: {
      track: {
        slug: track.slug,
        language: track.title
      }
    }, status: :ok
  end
end
