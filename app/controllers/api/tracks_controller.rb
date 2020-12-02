module API
  class TracksController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user

    def index
      tracks = Track::Search.(
        criteria: params[:criteria],
        tags: params[:tags],
        status: params[:status],
        user: current_user
      )

      render json: SerializeTracks.(tracks, current_user),
             status: :ok
    end

    def show
      begin
        track = Track.find_by!(slug: params[:id])
      rescue StandardError
        return render_404(:track_not_found, fallback_url: tracks_url)
      end

      render json: {
        track: {
          id: track.slug,
          language: track.title
        }
      }, status: :ok
    end
  end
end
