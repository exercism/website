module API
  class Mentoring::TracksController < BaseController
    def show
      render json: SerializeTracksForMentoring.(Track.all)
    end

    def mentored
      render json: SerializeTracksForMentoring.(current_user.mentored_tracks, mentor: current_user)
    end

    def update
      tracks = Track.where(slug: params[:track_slugs])

      current_user.update!(mentored_tracks: tracks)

      render json: SerializeTracksForMentoring.(current_user.mentored_tracks, mentor: current_user)
    end
  end
end
