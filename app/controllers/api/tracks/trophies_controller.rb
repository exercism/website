module API
  module Tracks
    class TrophiesController < BaseController
      def reveal
        begin
          track = Track.find(params[:track_slug])
        rescue StandardError
          return render_404(:track_not_found, fallback_url: tracks_url)
        end

        trophy = UserTrack::AcquiredTrophy.find_by(uuid: params[:uuid])

        return render_404(:trophy_not_found) unless trophy
        return render_403(:trophy_not_accessible) unless trophy.user == current_user
        return render_403(:trophy_not_accessible) unless trophy.track == track

        UserTrack::AcquiredTrophy::Reveal.(trophy)

        render json: {}, status: :ok
      end
    end
  end
end
