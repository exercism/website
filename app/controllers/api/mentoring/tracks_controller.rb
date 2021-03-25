module API
  class Mentoring::TracksController < BaseController
    def show
      tracks = Track::Search.(criteria: params[:criteria], user: current_user)

      render json: SerializeTracksForMentoring.(tracks)
    end

    def mentored
      tracks = Track::Search.(criteria: params[:criteria], user: current_user)
      tracks = current_user.mentored_tracks.where(id: tracks)
      render json: SerializeTracksForMentoring.(tracks, mentor: current_user)
    end

    def update
      tracks = Track.where(slug: params[:track_slugs])

      current_user.update!(mentored_tracks: tracks)

      render json: SerializeTracksForMentoring.(current_user.mentored_tracks, mentor: current_user)
    end
  end
end
