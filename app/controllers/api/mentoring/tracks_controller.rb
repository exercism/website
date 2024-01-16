class API::Mentoring::TracksController < API::BaseController
  def show
    tracks = Track::Search.(criteria: params[:criteria], user: current_user)

    render json: {
      tracks: SerializeTracksForMentoring.(tracks, current_user)
    }
  end

  def mentored
    tracks = Track::Search.(criteria: params[:criteria], user: current_user)
    tracks = current_user.mentored_tracks.where(id: tracks)
    render json: {
      tracks: SerializeTracksForMentoring.(tracks, current_user)
    }
  end

  def update
    tracks = Track.where(slug: params[:track_slugs])
    Mentor::UpdateMentoredTracks.(current_user, tracks)

    render json: {
      tracks: SerializeTracksForMentoring.(current_user.mentored_tracks, current_user)
    }
  end
end
