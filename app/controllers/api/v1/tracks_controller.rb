class API::V1::TracksController < API::BaseController
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
